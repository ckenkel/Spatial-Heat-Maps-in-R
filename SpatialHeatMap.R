library(ggplot2)
library(ggmap)
library(RColorBrewer) # for color selection
library(splitstackshape) #for expanding dataframe based on counts
library(MCMC.OTU)

############################################
#See http://trucvietle.me/r/tutorial/2017/01/18/spatial-heat-map-plotting-using-r.html
#for example tutorial on which the script below is based

########################################################

#read in coral cover data. NOTE change these to YOUR local file path 
data <- read.csv(file="/Users/drcarl/Dropbox/CarlsLab/ResearchProjects/RGWGshared/Rscripts/CREMP_Core_Species_Percent_Cover_Table.csv")

gps<-read.csv(file="/Users/drcarl/Dropbox/CarlsLab/ResearchProjects/RGWGshared/Rscripts/Coral_Reef_Evaluation_and_Monitoring_Project_CREMP_Locations.csv")
head(gps)

#subset gps to useful columns only
gps<-gps[,c(6,9,15,16)]


#Put the two dataframes together
dataAll<-merge(gps,data,by=c("siteid","stationid"))

head(dataAll)

#Values are all very low. Will not be useful for spatial heatmapping. Solution: multiply all by 1000  
dAtrans<-(dataAll[,11:50]*1000)
dAtrans<-cbind(dataAll[,1:10],dAtrans)
head(dAtrans)


## Convert year to factor
dAtrans$Sample_Year <- as.factor(dAtrans$Sample_Year)

##Loglin transform cover data to reduce spread of scale for spatial mapping. Otherwise heatmap scale is insane. (approximates variance stabilizing transformation because most data points are zeros, but some are very high)

############################################

logLinOnly <- function(data, count.columns, k = 10, zero.na = FALSE){
	nn = data[, count.columns]
	vtr = c()
    for (n in 1:length(nn[, 1])) {
       nx = nn[n, ]
        nxk = (nx <= k)
        nxK = (nx > k)
        nx[nxK] = log(nx[nxK])
       nx[nxk] = nx[nxk]/k + log(k) - 1
        vtr = data.frame(rbind(vtr, nx))
     }
    if (zero.na) {
         vtr[nn == 0] = NA
     }
     return(vtr)
 }

# ######################################################

 head(dAtrans)

 dataNorm<-round(logLinOnly(dAtrans,count.columns=c(11:50),k=10,zero.na=FALSE))

 dataNorm<-cbind(dAtrans[,1:10],dataNorm)

 summary(dataNorm)


### Subset to LK only to make plot a bit clearer; note, could be repeated for any subRegion
Upper<-subset(dataNorm,subRegionId=="LK")

##### IMPORTANT: RETAIN ONLY SITES FOR WHICH THE FULL 20 YRS OF DATA IS AVAILABLE
#B/c some CREMP sites were added later in the program. This will throw off the spatial incidence
#To find this, look at CREMP Locations sheet, columns "First_Year" "Last_Year", remove those not 1996-2015
Upper2<-subset(Upper,sitename!="Wonderland")
Upper3<-subset(Upper2,sitename!="Red Dun Reef")

## Specify a map with center at the center of all the coordinates
mean.longitude <- c(-81.59708)#mean(Upper$lonDD) #c(-80.46985) #note, scooted the map a bit from the original mean
mean.latitude <- mean(Upper$latDD)

#Now, pull down and store a map
keys.map <- get_map(location = c(mean.longitude, mean.latitude), zoom =10, scale = 2, maptype="satellite")

## Convert into ggmap object
keys.map <- ggmap(keys.map, extent="device", legend="none")

#names(Upper3)
#Particular species of interest by column number
#OannComplex=39; Acer=11; Apal=12; Past=40; Cnat=17; Pseudodip=42&43; Sidsid=47; StephInt=49; Mcav=32
#Stephanocoenia_intersepta Siderastrea_siderea Pseudodiploria_clivosa Pseudodiploria_strigosa Colpophyllia_natans Acropora_palmata Porites_astreoides Montastraea_cavernosa  Orbicella_annularis_complex

ACER<-Upper3[,c(3,4,6,40)] #change last column number to your favorite species

#stat_density fcn uses each row as incidence data. therefore must expand selected column to indicate N rows
dfexp <- expandRows(ACER, "Porites_astreoides") #change species name here to match column header

## Plot a heat map layer: Polygons with fill colors based on
## relative coral cover
keys.map <- keys.map + stat_density2d(data=dfexp,aes(x=lonDD, y=latDD, fill=..level.., alpha=..level..), geom="polygon")

## Define the spectral colors to fill the density contours
keys.map <- keys.map + scale_fill_gradientn(colours=rev(brewer.pal(7, "Spectral")))

## Remove any legends
keys.map <- keys.map + guides(size=FALSE, alpha = FALSE)

## Give the map a title
keys.map <- keys.map + ggtitle("Relative Change in Percent Cover of P. astreoides from 1996 to 2015") #change spp name



## Subset to Plot coral cover by year
keys.map <- keys.map + facet_wrap(~Sample_Year) +theme_bw() 

#Export PDF
pdf(file="Past_CREMP_LogLinCoralCover_ByYear.pdf",height=11,width=8) #change spp name
print(keys.map) # this is necessary to display the plot
dev.off()


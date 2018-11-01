# Spatial-Heat-Maps-in-R
Create spatial heatmaps to illustrate the relative percent change in coral cover over time at a given location. 

------------------------------------------------------------

Carly Kenkel, ckenkel@usc.edu

See http://trucvietle.me/r/tutorial/2017/01/18/spatial-heat-map-plotting-using-r.html for an example tutorial on which this script is based.

This code will generate spatial heatmaps showing the relative change in percent cover of focal coral species.
The example input files are reef survey data spanning 20 years of observations in the Lower Florida Keys, USA. 
Coral cover data was obtained from the fixed CREMP survey stations, http://geodata.myfwc.com/datasets/02659342308142349932ab101c1d8a6b_14/data 
omitting sites for which the full 20 years of data were not available. 

Raw survey data are multiplied by 1000 and log-linear-hybrid transformed and rounded to the nearest whole number. 
A spatial heatmap is plotted by converting cover to density of particular survey coordinates and using these as the shading parameter. 

This visual is meant to serve as a ‘for example’ as a means to assess and re-evaluate restoration needs.

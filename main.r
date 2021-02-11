# ########################## Install Dependencies ###############################

# SF package called Simple features
if(!require(sf)){
  install.packages("sf")
}
# ggplot2 is a system for declaratively creating graphics
# The easiest way to get ggplot2 is to install the whole tidyverse:
# install.packages("tidyverse")
# Alternatively, install just ggplot2:
if(!require(ggplot2)){
  install.packages("ggplot2")
}
# Install the Tmap Package for interactive maps
if(!require(tmap)){install.packages("tmap")}


# Library for interactive maps
if(!require(leaflet)){install.packages("leaflet")}
# dplyr is a grammar of data manipulation providing a consistent set of verbs that help you solve the most common data manipulation challenges:
# The easiest way to get dplyr is to install the whole tidyverse:
# install.packages("tidyverse")
# Alternatively, install just dplyr:
if(!require(dplyr)){install.packages("dplyr")}
# IO Tool to import CSV files and such
if(!require(readr)){install.packages("readr")}

# package to generate bivariate color palettes
if(!require(readr)){install.packages("pals")}

library(sf)
library(ggplot2)
library(tmap)
library(leaflet)
library(dplyr)
library(readr)
library(pals)


# ################################### BEGINNING OF SCRIPT #######################################
############ L1 Data

# importing the data from the csv
data <- readr::read_delim(file = "data.csv", delim = ":",col_names = FALSE)

# formatting the date correctly
data <- data.frame(wilaya = data$X1, incidence_1= data$X2, incidence_2= data$X3)

# importing the map from the shapefiles
mymap <- st_read("dz_map/dzaBound.shp")

names(mymap)[names(mymap) == "NAME_2"] <- "wilaya"

map_and_data <- inner_join(data, mymap)

ggplot(data= map_and_data) + geom_sf(aes(fill = incidence_1))


############ S1 Data, univariate Choropleth 

# importing the data from data2.csv
data <- readr::read_delim(file = "data2.csv", delim = ":",col_names = FALSE)

# correct labeling
data <- data.frame(wilaya = data$X1, sting= data$X2, incidence= data$X3, deaths=data$X4, lethality=data$X5)

# importing the map
mymap <- st_read("dz_map/dzaBound.shp")

# correct labeling
names(mymap)[names(mymap) == "nam"] <- "wilaya"

map_and_data <- inner_join(data, mymap)

# Basic Map draw
ggplot(data = mymap) + geom_sf() + xlab("Longitude") + ylab("Latitude") + ggtitle("Algeria MAP") + geom_sf(color = "black", fill = "red")

# sting map
ggplot(data = map_and_data) + xlab("Longitude") + ylab("Latitude") + ggtitle("Algeria MAP") + geom_sf(aes(geometry = geometry, fill = sting)) + scale_fill_viridis_c(option = "viridis", trans="sqrt", begin = 0.3, end = 0.7)


# incidence map
ggplot(data = map_and_data) + xlab("Longitude") + ylab("Latitude") + ggtitle("Algeria MAP") + geom_sf(aes(geometry = geometry, fill = incidence)) + scale_fill_viridis_c(option = "plasma", trans="sqrt", begin = 0.2, end = 0.6)



# ################################### END OF SCRIPT #############################################

# Clear environment
rm(list = ls()) 

# Clear packages
detach("package:datasets", unload = TRUE)  # For base

# Clear console
cat("\014")  # ctrl+L

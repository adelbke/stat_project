# ########################## Install Dependencies ###############################

# SF package called Simple features
if(!require(sf)){
  install.packages("sf")
}
library(sf)

# ggplot2 is a system for declaratively creating graphics
# The easiest way to get ggplot2 is to install the whole tidyverse:
# install.packages("tidyverse")

# Alternatively, install just ggplot2:
if(!require(ggplot2)){
  install.packages("ggplot2")
}
library(ggplot2)

# Install the Tmap Package for interactive maps
if(!require(tmap)){install.packages("tmap")}
library(tmap)

# Library for interactive maps
if(!require(leaflet)){install.packages("leaflet")}
library(leaflet)

# dplyr is a grammar of data manipulation providing a consistent set of verbs that help you solve the most common data manipulation challenges:
# The easiest way to get dplyr is to install the whole tidyverse:
# install.packages("tidyverse")

# Alternatively, install just dplyr:
if(!require(dplyr)){install.packages("dplyr")}
library(dplyr)

# IO Tool to import CSV files and such
if(!require(readr)){install.packages("readr")}
library(readr)


# ################################### BEGINNING OF SCRIPT #######################################

data <- readr::read_delim(file = "data.csv", delim = ":",col_names = FALSE)

dtf <- data.frame(wilaya = data$X1, incidence_1= data$X2, incidence_2= data$X3)


# ################################### END OF SCRIPT #############################################

# Clear environment
rm(list = ls()) 

# Clear packages
detach("package:datasets", unload = TRUE)  # For base

# Clear console
cat("\014")  # ctrl+L

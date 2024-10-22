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

if(!require(cowplot)){install.packages("cowplot")}

library(sf)
library(tmap)
library(ggplot2)
library(tmap)
library(leaflet)
library(dplyr)
library(readr)
library(pals)
library(tidyr)
library(cowplot)

# ################################### BEGINNING OF SCRIPT #######################################

# importing the data from data2.csv
data <- readr::read_delim(file = "data2.csv", delim = ":",col_names = FALSE)

# correct labeling
data <- data.frame(wilaya = data$X1, sting= data$X2, incidence= data$X3, deaths=data$X4, lethality=data$X5)

# importing the map
mymap <- st_read("dz_map/dzaBound.shp")

# correct labeling
names(mymap)[names(mymap) == "nam"] <- "wilaya"
# consistent naming
mymap$wilaya[mymap$wilaya=="M'SILA"] <- "MSILA"

# clean the data from missing data
clean_data <- data %>% filter(!is.na(lethality), !is.na(incidence))

map_and_data <- inner_join(clean_data, mymap)


# calculate the quartiles for the lethality data
quantiles_lethality <- quantile(map_and_data$lethality, probs= seq(0, 1, length.out= 4))

# calculate the quartiles for the incidence data
quantiles_incidence <- quantile(map_and_data$incidence, probs= seq(0, 1, length.out= 4))

# Prepare the color palette

  # Bivariate color scale setup
  palette_matrix <- brewer.seqseq2() # brewer.seqseq2 is a bivariate palette that resists color blindness
  
  color_index_grid <- 
    expand.grid(lethality_palette=c(1,2,3),incidence_palette=c(1,2,3)) # create 1,2,3 pairs in data.frame
  # arrange(desc(row_number())) # reverse the order to fit the color palette

  # calculate the color grid
  color_scale_grid <- data.frame(group=paste(color_index_grid$lethality_palette, "-", color_index_grid$incidence_palette), fill= palette_matrix, lethality=color_index_grid$lethality_palette, incidence=color_index_grid$incidence_palette)  
  

# assign each line of data to a color
  map_and_data %<>% 
    mutate(
      lethality_quantiles= cut(
        map_and_data$lethality,
        breaks = quantiles_lethality,
        include.lowest = TRUE
      ),
      
      incidence_quantiles = cut(
        map_and_data$incidence,
        breaks = quantiles_incidence,
        include.lowest = TRUE
      ),
      group = paste(
        as.numeric(lethality_quantiles), "-",
        as.numeric(incidence_quantiles)
      )
    ) %>% left_join(color_scale_grid, by="group")

# import theme
  source("theme.r")

# Draw map
  data_map <- ggplot(data= map_and_data) +
    geom_sf(aes(geometry=geometry, fill=fill)) +
    scale_fill_identity() +
    labs(x = NULL,
         y = NULL,
         title = "Algeria's regional leathality and incidence",
         subtitle = paste0("bivariate choropleth ",
                           ""),
         caption = "") +
    geom_sf_label(aes(geometry=geometry, label = wilaya), size=2.25) +
    theme_map()

# Draw Legend
  legend <- ggplot() +
    geom_tile(
      data= color_scale_grid,
      mapping =aes(
        x = lethality,
        y = incidence,
        fill = fill
      )
    ) + scale_fill_identity() + labs(x = "Higher lethality ⟶️",y = "Higher incidence ⟶️")
  
  ggdraw() +
    draw_plot(data_map, 0, 0, 1, 1) +
    draw_plot(legend, 0.05, 0.05, 0.2, 0.3)
  
  # ################################### END OF SCRIPT #############################################

# Clear environment
rm(list = ls()) 

# Clear packages
detach("package:datasets", unload = TRUE)  # For base

# Clear console
cat("\014")  # ctrl+L

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
mymap$wilaya[mymap$wilaya=="M'SILA"] <- "MSILA"

# clean the data from missing data
clean_data <- data %>% filter(!is.na(sting), !is.na(deaths))

map_and_data <- inner_join(clean_data, mymap)


# calculate the quartiles for the death data
quantiles_deaths <- quantile(map_and_data$deaths, probs= seq(0, 1, length.out= 4))

# calculate the quartiles for the sting data
quantiles_stings <- quantile(map_and_data$sting, probs= seq(0, 1, length.out= 4))

# Bivariate color scale setup
palette_matrix <- brewer.seqseq2() # brewer.seqseq2 is a bivariate palette that resists color blindness
# palette_matrix <- stevens.bluered()

color_index_grid <- 
  expand.grid(deaths_palette=c(1,2,3),stings_palette=c(1,2,3)) # create 1,2,3 pairs in data.frame
  # arrange(desc(row_number())) # reverse the order to fit the color palette

# calculate the color grid
color_scale_grid <- data.frame(group=paste(color_index_grid$deaths_palette, "-", color_index_grid$stings_palette), fill= palette_matrix, deaths=color_index_grid$deaths_palette, sting=color_index_grid$stings_palette)

geo_bivariate_data <- map_and_data

geo_bivariate_data %<>% 
  mutate(
    deaths_quantiles= cut(
      geo_bivariate_data$deaths,
      breaks = quantiles_deaths,
      include.lowest = TRUE
    ),
    
    sting_quantiles = cut(
      geo_bivariate_data$sting,
      breaks = quantiles_stings,
      include.lowest = TRUE
    ),
    group = paste(
      as.numeric(deaths_quantiles), "-",
      as.numeric(sting_quantiles)
    )
  ) %>% left_join(color_scale_grid, by="group")
  
  # import theme
source("theme.r") 
  data_map <- ggplot(data= geo_bivariate_data) +
    geom_sf(aes(geometry=geometry, fill=fill)) +
    scale_fill_identity() +
    labs(x = NULL,
         y = NULL,
         title = "Algeria's regional Stings By Death",
         subtitle = paste0("Algeria 20XX",
                           ""),
         caption = "") +
    geom_sf_label(aes(geometry=geometry, label = wilaya),size=2.25) +
    theme_map()
  
  # color_scale_grid %<>%
  #   separate(group, into = c("sting", "deaths"), sep = "-") %>%
  #   mutate(sting = as.integer(sting),
  #          deaths = as.integer(deaths))
  
  legend <- ggplot() +
    geom_tile(
      data= color_scale_grid,
      mapping =aes(
        x = sting,
        y = deaths,
        fill = fill
      )
    ) + scale_fill_identity() + labs(x = "Higher Sting ⟶️",y = "Higher Deaths ⟶️")
  
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

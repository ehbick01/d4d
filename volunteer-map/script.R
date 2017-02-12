# ---
# Title: Building D4D Volunteer Map
# ---

# Load packages
library(ggmap)
library(tidyverse)
library(leaflet)
library(htmlwidgets)

# # Read csv of volunteer addresses
# dat <- read_csv('addresses.csv')

# # Build full addresses
# dat$full_address <-
#   paste0(dat$City, ", ", dat$`State/Province`, ", ", dat$Country)
# 
# # Geocode and capture lon/lat
# dat$lon <- geocode(dat$full_address, output = 'latlon')$lon
# dat$lat <- geocode(dat$full_address, output = 'latlon')$lat

# Read csv of geocoded addresses
# -- This assumes addresses have already been geocoded per above
dat <- read_csv('addresses_geocoded.csv')

# Create dataframe of unique addresses and associated count of members at each
# -- This is to fix the issue of cities having various naming conventions
dat$lat_lon <- paste0(dat$lat, ":", dat$lon)

# Count unique of lat_lon key
dat_unique <- dat %>%
  group_by(lat_lon) %>%
  summarise('total' = n())

# Merge it back with original data
dat_final <- left_join(dat_unique, 
                       dat,
                       by = 'lat_lon')

# Remove duplicate keys
dat_final <- dat_final[!duplicated(dat_final$lat_lon), ]

## Build Leaflet Map

# Make icon
d4dIcon <- makeIcon(
  iconUrl = "icon.png",
  iconAnchorX = 16,
  iconAnchorY = 16)

map_icon <- leaflet() %>%
  addProviderTiles("OpenStreetMap.BlackAndWhite",
                   options = tileOptions(minZoom = 0, maxZoom = 18)) %>%
  addMarkers(
    lng = dat_final$lon,
    lat = dat_final$lat,
    popup = paste0(
      "<strong>Address: </strong>",
      dat_final$full_address,
      "<br><strong>Number of Volunteers: </strong>",
      dat_final$total
    ),
    icon = d4dIcon)

# Save map
saveWidget(map_icon, file = 'd4d-volunteer-map.html', selfcontained = T)

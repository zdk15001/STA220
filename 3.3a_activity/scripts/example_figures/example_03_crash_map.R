# scripts/example_figures/example_03_crash_map.R
# Example 3: Where on the Parkway do crashes bunch up?
#   New: a map with layers (each geom_sf() brings its own data, drawn in the order you write them),
#   and geom_bin_2d(), a histogram in two directions: it cuts the map into squares and counts the
#   crashes in each one. Darker means more crashes.
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

pine_towns <- read_sf("data/pine_towns.gpkg")

highway_sections <- read_sf("data/highway_sections.gpkg")

highway_crashes <- read_sf("data/highway_crashes.gpkg")      # one row per crash, with its x and y

# One colour per section, the same in every example
section_colours <- c(
  "Dogwood Curve"      = "#2a78d6",
  "Elm Bridge"         = "#eb6834",
  "Cedar Interchange"  = "#1baf7a",
  "Birch Straightaway" = "#eda100"
)


# COPY FROM HERE (down to STOP HERE) -------------------------------------------------------------

# For the bike data, change:
#   highway_crashes   to  bike_crashes
#   highway_sections  to  bike_corridors
#   section_colours   to  corridor_colours
#   section           to  corridor
#   binwidth = 0.5    to  binwidth = 0.25   (the streets are short: use quarter-mile squares)
#   Then change the words in labs() to fit your argument: title, subtitle, fill, and colour.


# The Figure -------------------------------------------------------------------------------------

# binwidth = 0.5 makes half-mile squares. Like a histogram, try a few widths and see what changes!
fig_03 <- ggplot() +
  geom_sf(data = pine_towns, fill = "grey95", colour = "white") +
  geom_sf_text(data = pine_towns, aes(label = town), colour = "grey50") +
  geom_bin_2d(data = highway_crashes, aes(x = x, y = y), binwidth = 0.5) +
  geom_sf(data = highway_sections, aes(colour = section), linewidth = 1.5) +
  scale_fill_distiller(palette = "Greys", direction = 1) +
  scale_colour_manual(values = section_colours) +
  labs(
    title = "Crashes bunch up on Elm Bridge and the middle of Dogwood Curve",
    subtitle = "Each square is half a mile on a side. The darker the square, the more crashes in it.",
    fill = "Crashes,\n2021 to 2025",
    colour = "Section",
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_void()

fig_03


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_03_crash_map.png", fig_03, width = 7.5, height = 5.5, bg = "white")

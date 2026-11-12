# scripts/example_figures/example_06_traffic_map.R
# Example 6: Which section carries the most cars? (The same numbers as Example 2, drawn on a map.)
#   New: left_join() a table onto the shapes (shapes go on the left, so it stays a map, as in 3.3),
#   and linewidth mapped to a number: the thicker the line, the more traffic.
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

pine_towns <- read_sf("data/pine_towns.gpkg")

highway_sections <- read_sf("data/highway_sections.gpkg")

highway_yearly <- read_csv("data/highway_yearly.csv")

# One colour per section, the same in every example
section_colours <- c(
  "Dogwood Curve"      = "#2a78d6",
  "Elm Bridge"         = "#eb6834",
  "Cedar Interchange"  = "#1baf7a",
  "Birch Straightaway" = "#eda100"
)


# COPY FROM HERE (down to STOP HERE) -------------------------------------------------------------

# For the bike data, change:
#   highway_sections  to  bike_corridors
#   highway_yearly    to  bike_yearly
#   highway_2025      to  bike_2025
#   section_colours   to  corridor_colours
#   section           to  corridor
#   vehicles_per_day  to  bikes_per_day (riders) or cars_per_day
#   Then change the words in labs() to fit your argument: title, subtitle, colour, and linewidth.


# One Number for Each Line -----------------------------------------------------------------------

highway_2025 <- highway_yearly |>
  filter(year == 2025) |>
  select(section, vehicles_per_day)

sections_2025 <- highway_sections |>
  left_join(highway_2025, by = "section")

# Expect 4 rows, with vehicles_per_day filled in for every section
sections_2025


# The Figure -------------------------------------------------------------------------------------

fig_06 <- ggplot() +
  geom_sf(data = pine_towns, fill = "grey95", colour = "white") +
  geom_sf_text(data = pine_towns, aes(label = town), colour = "grey50") +
  geom_sf(data = sections_2025, aes(colour = section, linewidth = vehicles_per_day)) +
  scale_colour_manual(values = section_colours) +
  labs(
    title = "Elm Bridge carries more cars than any other section",
    subtitle = "Average vehicles per day in 2025. The thicker the line, the more traffic.",
    colour = "Section",
    linewidth = "Vehicles per day",
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_void()

fig_06


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_06_traffic_map.png", fig_06, width = 7.5, height = 5.5, bg = "white")

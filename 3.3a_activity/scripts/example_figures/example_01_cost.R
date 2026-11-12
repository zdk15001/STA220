# scripts/example_figures/example_01_cost.R
# Example 1: What would a third lane cost on each section?
#   New: nothing! geom_col() draws a number that is already in the table (3.1).
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

highway_sections <- read_sf("data/highway_sections.gpkg")     # one row per section


# COPY FROM HERE (down to STOP HERE) -------------------------------------------------------------

# For the bike data, change:
#   highway_sections  to  bike_corridors
#   section           to  corridor
#   Then change the words in labs() to fit your argument: title and y.


# The Figure -------------------------------------------------------------------------------------

fig_01 <- ggplot(highway_sections, aes(x = section, y = cost_million)) +
  geom_col() +
  labs(
    title = "Birch Straightaway is the cheapest place to add a lane",
    x = NULL,
    y = "Cost to add a lane (millions of dollars)",
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_minimal()

fig_01


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_01_cost.png", fig_01, width = 7, height = 4.5, bg = "white")

# scripts/example_figures/example_10_tradeoffs.R
# Example 10: Which section would a new lane cost the least? Everything it would take, one panel each.
#   New: pivot_longer() on four columns at once, and facet_wrap(scales = "free_x") so dollars, homes,
#   acres, and years each get their own axis. my_section is drawn on top in its own colour.
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

highway_sections <- read_sf("data/highway_sections.gpkg")     # one row per section

my_section <- "Birch Straightaway"          # the section this figure argues for


# COPY FROM HERE (down to STOP HERE) -------------------------------------------------------------

# For the bike data, change:
#   highway_sections  to  bike_corridors
#   my_section        to  my_corridor
#   section           to  corridor
#   homes_affected    to  parking_lost
#   wetland_acres     to  trees_removed
#   "Homes affected"  to  "Parking spaces lost"
#   "Wetland acres"   to  "Trees removed"
#   "#eda100"         to  your street's colour (the codes are at the top of your script)
#   Then change the words in labs() to fit your argument: title and subtitle.


# One Row Per Section Per Measure ----------------------------------------------------------------

# -section means "every column except section"
tradeoffs <- highway_sections |>
  st_drop_geometry() |>
  select(section, cost_million, homes_affected, wetland_acres, years_to_build) |>
  rename(
    "Cost (millions of dollars)" = cost_million,
    "Homes affected" = homes_affected,
    "Wetland acres" = wetland_acres,
    "Years to build" = years_to_build
  ) |>
  pivot_longer(-section, names_to = "measure", values_to = "value")

# Expect 16 rows: 4 sections x 4 measures
tradeoffs

mine <- tradeoffs |>
  filter(section == my_section)


# The Figure -------------------------------------------------------------------------------------

fig_10 <- ggplot(tradeoffs, aes(x = value, y = section)) +
  geom_col(fill = "grey75") +
  geom_col(data = mine, fill = "#eda100") +
  facet_wrap(~ measure, scales = "free_x") +
  labs(
    title = "Birch Straightaway costs the least in every way",
    subtitle = "What adding a lane would take: dollars (millions), homes, wetland acres, and years.\nShorter bars are better.\nBirch Straightaway takes no homes or wetlands, so it has no bar in those two panels.",
    x = NULL,
    y = NULL,
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_minimal()

fig_10


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_10_tradeoffs.png", fig_10, width = 7.5, height = 5, bg = "white")

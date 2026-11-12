# scripts/example_figures/example_13_town_rate_map.R
# Example 13: Which town's residents see the most Parkway crashes?
#   New: count() the crashes in each town (every crash has a town column), join the counts onto the
#   town shapes, make a rate (crashes per 1,000 residents), and shade each town by it (3.3).
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

pine_towns <- read_sf("data/pine_towns.gpkg")                  # one row per town, with pop

highway_sections <- read_sf("data/highway_sections.gpkg")

highway_crashes <- read_sf("data/highway_crashes.gpkg")        # one row per crash, with its town


# COPY FROM HERE (down to STOP HERE) -------------------------------------------------------------

# For the bike data, change:
#   highway_crashes   to  bike_crashes
#   highway_sections  to  bike_corridors
#   Cedar and Fir have none of the four streets, so they have no bike crashes to count and the
#   map draws them grey. Say what grey means on the figure!
#   Then change the words in labs() to fit your argument: title, subtitle, and fill.


# A Rate for Each Town ---------------------------------------------------------------------------

crashes_by_town <- highway_crashes |>
  st_drop_geometry() |>
  count(town)

# Expect 5 rows: Alder has no Parkway, so it has no crashes to count
crashes_by_town

# The towns go on the left, so towns_rate is still a map
towns_rate <- pine_towns |>
  left_join(crashes_by_town, by = "town") |>
  mutate(crashes_per_1000 = n / pop * 1000)

# Expect 6 rows. Alder's n is NA, so the map draws it grey: say what grey means on the figure!
towns_rate


# The Figure -------------------------------------------------------------------------------------

fig_13 <- ggplot() +
  geom_sf(data = towns_rate, aes(fill = crashes_per_1000), colour = "white") +
  geom_sf(data = highway_sections) +
  geom_sf_text(data = towns_rate, aes(label = town)) +
  scale_fill_distiller(palette = "Reds", direction = 1) +
  labs(
    title = "For the people who live there, Dogwood has the most Parkway crashes",
    subtitle = "Each town's Parkway crashes, 2021 to 2025, per 1,000 residents. The black line is the Parkway.\nAlder (grey) has no Parkway, so it has no Parkway crashes.",
    fill = "Crashes per\n1,000 residents",
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_void()

fig_13


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_13_town_rate_map.png", fig_13, width = 7.5, height = 5.5, bg = "white")

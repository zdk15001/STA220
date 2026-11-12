# scripts/example_figures/example_11_growth_and_serious_map.R
# Example 11: A map with two stories. Where is traffic growing, and where do people get badly hurt?
#   New: only some of the points drawn (filter() before the layer), on top of lines whose width
#   shows how much traffic grew. The growth is the same pivot_wider() as Example 5, and the join
#   onto the shapes is the same as Example 6.
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

pine_towns <- read_sf("data/pine_towns.gpkg")

highway_sections <- read_sf("data/highway_sections.gpkg")

highway_yearly <- read_csv("data/highway_yearly.csv")

highway_crashes <- read_sf("data/highway_crashes.gpkg")

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
#   highway_crashes   to  bike_crashes
#   section_colours   to  corridor_colours
#   section           to  corridor
#   vehicles_per_day  to  bikes_per_day
#   "vehicles_"       to  "bikes_"
#   vehicles_2025     to  bikes_2025
#   vehicles_2016     to  bikes_2024   (not bikes_2023: Station Road has no 2023 rider count, so
#                                       its change would be NA and the figure stops with an error)
#   Then change the words in labs() to fit your argument: title, subtitle, colour, and linewidth.


# The Growth for Each Line, and the Points to Show ------------------------------------------------

growth <- highway_yearly |>
  select(section, year, vehicles_per_day) |>
  pivot_wider(names_from = year, values_from = vehicles_per_day, names_prefix = "vehicles_") |>
  mutate(pct_change = (vehicles_2025 - vehicles_2016) / vehicles_2016 * 100) |>
  select(section, pct_change)

sections_growth <- highway_sections |>
  left_join(growth, by = "section")

# Expect 4 rows, with pct_change filled in for every section
sections_growth

serious_crashes <- highway_crashes |>
  filter(severity == "serious or fatal")

# Expect 99 rows: one per serious or fatal crash
dim(serious_crashes)


# The Figure -------------------------------------------------------------------------------------

fig_11 <- ggplot() +
  geom_sf(data = pine_towns, fill = "grey95", colour = "white") +
  geom_sf_text(data = pine_towns, aes(label = town), colour = "grey50") +
  geom_sf(data = sections_growth, aes(colour = section, linewidth = pct_change)) +
  geom_sf(data = serious_crashes, size = 1) +
  scale_colour_manual(values = section_colours) +
  labs(
    title = "Traffic grew fastest on Cedar Interchange, but serious crashes bunch up\non Dogwood Curve",
    subtitle = "The thicker the line, the more its traffic grew, 2016 to 2025.\nEach black dot is a serious or fatal crash, 2021 to 2025.",
    colour = "Section",
    linewidth = "Percent change\nin traffic",
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_void()

fig_11


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_11_growth_and_serious_map.png", fig_11, width = 7.5, height = 5.5, bg = "white")

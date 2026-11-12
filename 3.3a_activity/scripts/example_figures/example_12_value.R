# scripts/example_figures/example_12_value.R
# Example 12: Where does a dollar go furthest? The size of the problem divided by the price of the fix.
#   New: a number built from three tables (hours lost to rush hour in a year, from the hourly table,
#   the yearly table, and the sections), joined with two left_join()s, then divided by the cost.
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

highway_sections <- read_sf("data/highway_sections.gpkg")

highway_yearly <- read_csv("data/highway_yearly.csv")

highway_hourly <- read_csv("data/highway_hourly.csv")

my_section <- "Birch Straightaway"          # the section this figure argues for


# COPY FROM HERE (down to STOP HERE) -------------------------------------------------------------

# For the bike data, this one takes more than swaps! Bikes have no rush-hour delay, so divide
# something else by the cost. For riders per $1 million, change:
#   highway_sections   to  bike_corridors
#   highway_yearly     to  bike_yearly
#   my_section         to  my_corridor
#   section            to  corridor
#   rush_delay_min     to  bikes_per_day
#   hours_per_million  to  riders_per_million
#   "#eda100"          to  your street's colour (the codes are at the top of your script)
#   Delete Step 1. In Step 3, delete the left_join(rush_vehicles, ...) line and the delay_hours
#   line. In the riders_per_million line, change delay_hours to bikes_per_day.
#   For crashes per $1 million, 2023 to 2025: in Step 2, put group_by(corridor) and
#   summarize(crashes = sum(crashes)) in place of filter() and select(), then divide crashes by
#   cost_million.
#   Then change the words in labs() to fit your argument: title, subtitle, x, and caption.


# Hours Lost to Rush Hour, per Million Dollars ----------------------------------------------------

# Step 1: how many vehicles drive each section in the rush hours (7 and 8 a.m.; 4, 5, and 6 p.m.)
rush_vehicles <- highway_hourly |>
  filter(hour %in% c(7, 8, 16, 17, 18)) |>
  group_by(section) |>
  summarize(rush_vehicles = sum(vehicles_per_hour))

# Step 2: how many minutes each of them loses
delay_2025 <- highway_yearly |>
  filter(year == 2025) |>
  select(section, rush_delay_min)

# Step 3: put the problem next to the price. Minutes / 60 = hours, x 250 weekdays in a year.
value <- highway_sections |>
  st_drop_geometry() |>
  select(section, cost_million) |>
  left_join(rush_vehicles, by = "section") |>
  left_join(delay_2025, by = "section") |>
  mutate(
    delay_hours = rush_vehicles * rush_delay_min / 60 * 250,
    hours_per_million = delay_hours / cost_million
  )

# Expect 4 rows, one per section
value

mine <- value |>
  filter(section == my_section)


# The Figure -------------------------------------------------------------------------------------

fig_12 <- ggplot(value, aes(x = hours_per_million, y = fct_reorder(section, hours_per_million))) +
  geom_col(fill = "grey75") +
  geom_col(data = mine, fill = "#eda100") +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "A dollar goes furthest against rush hour on Birch Straightaway",
    subtitle = "Hours lost to rush hour in a year, for each $1 million it would cost to add a lane",
    x = "Hours of delay per $1 million",
    y = NULL,
    caption = "Hours lost = vehicles in the five rush hours x minutes of delay / 60 x 250 weekdays.\nMade-up data for practice. Pine County does not exist."
  ) +
  theme_minimal()

fig_12


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_12_value.png", fig_12, width = 7, height = 4.5, bg = "white")

# scripts/example_figures/example_02_traffic.R
# Example 2: Which section carries the most cars?
#   New: filter() to one year, fct_reorder() to sort the bars (3.2), and commas in the axis numbers.
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)

highway_yearly <- read_csv("data/highway_yearly.csv")     # one row per section per year


# COPY FROM HERE (down to STOP HERE) -------------------------------------------------------------

# For the bike data, change:
#   highway_yearly    to  bike_yearly
#   highway_2025      to  bike_2025
#   section           to  corridor
#   vehicles_per_day  to  bikes_per_day (riders) or cars_per_day
#   Then change the words in labs() to fit your argument: title, subtitle, and x.


# One Year ---------------------------------------------------------------------------------------

highway_2025 <- highway_yearly |>
  filter(year == 2025)

# Expect 4 rows, one per section
highway_2025


# The Figure -------------------------------------------------------------------------------------

fig_02 <- ggplot(highway_2025, aes(x = vehicles_per_day, y = fct_reorder(section, vehicles_per_day))) +
  geom_col() +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Elm Bridge carries more cars than any other section",
    subtitle = "Average vehicles per day, 2025",
    x = "Vehicles per day",
    y = NULL,
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_minimal()

fig_02


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_02_traffic.png", fig_02, width = 7, height = 4.5, bg = "white")

# scripts/example_figures/example_04_traffic_over_time.R
# Example 4: Where is traffic growing?
#   New: geom_line() with colour mapped to section (3.2), and the same colour for each section
#   every time (a named list of colours, like party_colours in 3.3).
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)

highway_yearly <- read_csv("data/highway_yearly.csv")     # one row per section per year

# One colour per section, the same in every example
section_colours <- c(
  "Dogwood Curve"      = "#2a78d6",
  "Elm Bridge"         = "#eb6834",
  "Cedar Interchange"  = "#1baf7a",
  "Birch Straightaway" = "#eda100"
)


# COPY FROM HERE (down to STOP HERE) -------------------------------------------------------------

# For the bike data, change:
#   highway_yearly    to  bike_yearly
#   section_colours   to  corridor_colours
#   section           to  corridor
#   vehicles_per_day  to  bikes_per_day (riders) or cars_per_day
#   2016:2025         to  2023:2025
#   Station Road has no 2023 rider count (NA), so its line starts in 2024. R warns that it
#   removed the missing values, and that is okay. Say why on the figure!
#   For months in place of years: bike_monthly, x = month, and delete the scale_x_continuous() line.
#   Then change the words in labs() to fit your argument: title, subtitle, y, and colour.


# The Figure -------------------------------------------------------------------------------------

fig_04 <- ggplot(highway_yearly, aes(x = year, y = vehicles_per_day, colour = section)) +
  geom_line() +
  geom_point() +
  scale_colour_manual(values = section_colours) +
  scale_x_continuous(breaks = 2016:2025) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Cedar Interchange has gained the most cars since 2019",
    subtitle = "Average vehicles per day, 2016 to 2025. Cedar's warehouses opened in 2019.\nEvery section dipped in 2020 (COVID-19).",
    x = NULL,
    y = "Vehicles per day",
    colour = "Section",
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_minimal()

fig_04


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_04_traffic_over_time.png", fig_04, width = 7.5, height = 4.5, bg = "white")

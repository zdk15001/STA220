# scripts/example_figures/example_08_rush_hour.R
# Example 8: Where does rush hour hurt? An average weekday, hour by hour.
#   New: facet_wrap() with one panel per section (3.2), and geom_hline() for a reference line that
#   comes from the data (each section's own speed limit), so the column goes inside aes().
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)

highway_hourly <- read_csv("data/highway_hourly.csv")     # one row per section per hour

# Expect 96 rows (4 sections x 24 hours): hour 0 is midnight, hour 17 is 5 p.m.
dim(highway_hourly)


# COPY FROM HERE (down to STOP HERE) -------------------------------------------------------------

# For the bike data, change:
#   highway_hourly  to  bike_hourly
#   section         to  corridor
#   avg_speed_mph   to  car_speed_mph (how fast the cars go) or bikes_per_hour (riders)
#   For bikes_per_hour, delete the geom_hline() line: riders have no speed limit.
#   Then change the words in labs() to fit your argument: title, subtitle, and y.


# The Figure -------------------------------------------------------------------------------------

fig_08 <- ggplot(highway_hourly, aes(x = hour, y = avg_speed_mph)) +
  geom_line() +
  geom_hline(aes(yintercept = speed_limit), linetype = "dashed") +
  facet_wrap(~ section) +
  scale_x_continuous(breaks = c(0, 6, 12, 18)) +
  labs(
    title = "At the evening rush, cars on Elm Bridge crawl at about 20 mph",
    subtitle = "Average speed on a weekday in 2025, hour by hour. Dashed line: the speed limit.",
    x = "Hour of the day (0 is midnight, 12 is noon, 18 is 6 p.m.)",
    y = "Average speed (miles per hour)",
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_minimal()

fig_08


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_08_rush_hour.png", fig_08, width = 7.5, height = 5, bg = "white")

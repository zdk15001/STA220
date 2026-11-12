# scripts/example_figures/example_09_severity.R
# Example 9: Where are crashes worst? What share of each section's crashes hurt someone?
#   New: geom_bar() counts rows (one row is one crash), and position = "fill" turns the counts into
#   shares that add to 1 in each bar (3.2). Colours by name: darker red is more severe.
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

highway_crashes <- read_sf("data/highway_crashes.gpkg")     # one row per crash, 2021 to 2025

# Expect 1,463 rows
dim(highway_crashes)

severity_colours <- c(
  "serious or fatal" = "#a50f15",
  "injury"           = "#fb6a4a",
  "no injury"        = "#fcbba1"
)


# COPY FROM HERE (down to STOP HERE) -------------------------------------------------------------

# For the bike data, change:
#   highway_crashes  to  bike_crashes
#   section          to  corridor
#   To show the type of crash (dooring, turning car, passing car, other) in place of the worst
#   injury: change severity to crash_type, and delete the scale_fill_manual() line (its colours
#   only name the severity levels).
#   Then change the words in labs() to fit your argument: title, subtitle, x, and fill.


# The Figure -------------------------------------------------------------------------------------

# fct_infreq() puts the most common level first (3.2). Here that orders the colours light to dark,
# and the last level (serious or fatal) sits against the axis, where it is easiest to compare.
fig_09 <- ggplot(highway_crashes, aes(y = section, fill = fct_infreq(severity))) +
  geom_bar(position = "fill") +
  scale_fill_manual(values = severity_colours) +
  labs(
    title = "One in ten crashes on Dogwood Curve kills or seriously injures someone",
    subtitle = "Each section's crashes, 2021 to 2025, by the worst injury in the crash",
    x = "Share of the section's crashes (1 is all of them)",
    y = NULL,
    fill = "Worst injury",
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_minimal()

fig_09


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_09_severity.png", fig_09, width = 7.5, height = 4.5, bg = "white")

# scripts/example_figures/example_07_count_vs_rate.R
# Example 7: Which section is most dangerous? The same crashes as a count and as a rate.
#   New: group_by() and summarize() to add up five years, left_join() to bring in each section's
#   length, a rate (crashes per 100 million vehicle-miles), pivot_longer() to stack the count and
#   the rate, and facet_wrap() to draw them as two panels, each with its own x-axis.
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

highway_yearly <- read_csv("data/highway_yearly.csv")

highway_sections <- read_sf("data/highway_sections.gpkg")


# COPY FROM HERE (down to STOP HERE) -------------------------------------------------------------

# For the bike data, change:
#   highway_sections     to  bike_corridors
#   highway_yearly       to  bike_yearly
#   section              to  corridor
#   vehicles_per_day     to  bikes_per_day
#   year >= 2021         to  !is.na(bikes_per_day)   (drops Station Road's 2023: no rider count)
#   count_2021_to_2025   to  count_2023_to_2025
#   rate_per_100m_miles  to  rate_per_100k_trips
#   (vehicles * miles) * 100000000  to  vehicles * 100000
#   The last one makes a rate for bikes: crashes per 100,000 bike trips.
#   The two names in quotes inside rename() are the panel titles. Change them to match!
#   Then change the words in labs() to fit your argument: title and subtitle.


# A Count and a Rate, 2021 to 2025 ---------------------------------------------------------------

section_miles <- highway_sections |>
  st_drop_geometry() |>
  select(section, miles)

# Vehicle-miles = vehicles in a year x the miles each one drives on the section
crashes_5yr <- highway_yearly |>
  filter(year >= 2021) |>
  group_by(section) |>
  summarize(
    count_2021_to_2025 = sum(crashes),
    vehicles = sum(vehicles_per_day * 365)
  ) |>
  left_join(section_miles, by = "section") |>
  mutate(rate_per_100m_miles = count_2021_to_2025 / (vehicles * miles) * 100000000)

# Expect 4 rows, one per section
crashes_5yr

# The two numbers become two rows per section: one for each panel
crashes_long <- crashes_5yr |>
  select(section, count_2021_to_2025, rate_per_100m_miles) |>
  rename(
    "Count: crashes, 2021 to 2025" = count_2021_to_2025,
    "Rate: crashes per 100 million miles" = rate_per_100m_miles
  ) |>
  pivot_longer(-section, names_to = "measure", values_to = "value")

# Expect 8 rows: 4 sections x 2 measures
crashes_long


# The Figure -------------------------------------------------------------------------------------

fig_07 <- ggplot(crashes_long, aes(x = value, y = section)) +
  geom_col() +
  facet_wrap(~ measure, scales = "free_x") +
  labs(
    title = "Elm Bridge has the most crashes, but Dogwood Curve has the highest rate",
    subtitle = "Left: crashes, 2021 to 2025. Right: crashes per 100 million miles driven.\nA rate divides by how much driving happens there.",
    x = NULL,
    y = NULL,
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_minimal()

fig_07


# STOP HERE --------------------------------------------------------------------------------------
# Do not copy the line below! It saves the example's picture, and yours would replace it.

ggsave("output/figures/example_07_count_vs_rate.png", fig_07, width = 8, height = 4.5, bg = "white")

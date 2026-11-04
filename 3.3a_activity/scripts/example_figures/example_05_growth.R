# scripts/example_figures/example_05_growth.R
# Example 5: Which section is growing fastest?
#   New: pivot_wider() to put each year in its own column, then a percent change (3.2), and
#   my_section: the one section the figure argues for, drawn again on top in its own colour.
#   Data: made up (see scripts/01_make_data.R)


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)

highway_yearly <- read_csv("data/highway_yearly.csv")     # one row per section per year

my_section <- "Cedar Interchange"          # the section this figure argues for


# Percent Change ---------------------------------------------------------------------------------

# names_prefix puts a word in front of each year, so the new columns are vehicles_2016 to
# vehicles_2025 (a column name should not start with a number).
# Percent change = (end - start) / start x 100
growth <- highway_yearly |>
  select(section, year, vehicles_per_day) |>
  pivot_wider(names_from = year, values_from = vehicles_per_day, names_prefix = "vehicles_") |>
  mutate(pct_change = (vehicles_2025 - vehicles_2016) / vehicles_2016 * 100)

# Expect 4 rows (one per section) and 12 columns (section, ten years, and pct_change)
growth

# The one row for my_section, to draw on top in its own colour
mine <- growth |>
  filter(section == my_section)


# The Figure -------------------------------------------------------------------------------------

fig_05 <- ggplot(growth, aes(x = pct_change, y = fct_reorder(section, pct_change))) +
  geom_col(fill = "grey75") +
  geom_col(data = mine, fill = "#1baf7a") +
  labs(
    title = "Traffic grew eight times as fast on Cedar Interchange\nas on any other section",
    subtitle = "Percent change in average vehicles per day, 2016 to 2025",
    x = "Percent change since 2016",
    y = NULL,
    caption = "Made-up data for practice. Pine County does not exist."
  ) +
  theme_minimal()

fig_05

ggsave("output/figures/example_05_growth.png", fig_05, width = 7, height = 4.5, bg = "white")

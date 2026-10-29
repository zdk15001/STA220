# scripts/03_math_vs_rent.R  
# Figure 1: near TCNJ, how does rent shape access to better schools? Are there some towns that over-or-underperform based upon their rent? 
#   Scatter plot with a line of best fit. 
#   In:  data/towns_merged.csv (made by 02_merge.R), and the benchmark, New Jersey, from
#        data/rent_clean_nj.csv and data/njgpa_clean_nj.csv (made by 01_import.R)
#   Out: output/figures/math_vs_rent.png
# Run 02_merge.R first.




# Packages and Load the Data ------------------------------------------------------------

library(tidyverse)

towns_merged <- read_csv(
  "data/towns_merged.csv",
  col_types = cols(
    geo_id = col_character(),
    district_code = col_character()
  )
)

# One row is one town on the dashboard: one point each. Expect 19 rows and 11 columns.
dim(towns_merged)
names(towns_merged)
summary(towns_merged)

# The benchmark, New Jersey average (median)
rent_nj <- read_csv(
  "data/rent_clean_nj.csv",
  col_types = cols(geo_id = col_character())
)

njgpa_nj <- read_csv(
  "data/njgpa_clean_nj.csv",
  col_types = cols(district_code = col_character())
)

# Expect 1 row each
dim(rent_nj)
rent_nj$median_rent

dim(njgpa_nj)
njgpa_nj$math_ready

dim(njgpa_nj)
njgpa_nj$ela_ready

# The Line, in Numbers  -----------------------------------------------------------------

# Draw least squares line
rent_line_math <- lm(math_ready ~ median_rent, data = towns_merged)

rent_line_math                     # slope 0.039: about 3.9 more points in math for every $100 of rent

rent_line_ela <- lm(ela_ready ~ median_rent, data = towns_merged)

rent_line_ela                     # slope 0.026: about 2.6 more points in reading for every $100 of rent

# Why math vs reading? Math showed bigger differences. 
# Doing this is violating an assumption of LM! Do you know which one?


# Above the line means better math results than the town's rent predicts; below, worse. 
# residual is the distance between what we observed and what we expected (actual minus predicted) in percentage points.
math_predictions <- towns_merged |>
  mutate(
    predicted = predict(rent_line_math),
    residual = math_ready - predicted
  ) |>
  select(town, median_rent, math_ready, predicted, residual) |>
  arrange(desc(residual))

math_predictions

# Giving towns a label ------------------------------------------------------------

# Label to 2 biggest overperformers, 2 biggest underperformers, and the best-predicted town. 
labeled <- towns_merged |>
  filter(town %in% c("Ewing township", "Burlington township", "Plainsboro township", "Trenton city", "Princeton", "Hamilton township", "East Windsor township")) |>
  mutate(short = str_remove(town, " township| city"))


# The Figure  ----------------------------------------------------------------------------

fig1 <- ggplot(
  towns_merged,
  aes(
    x = median_rent,
    y = math_ready
  )
) +
  geom_vline(xintercept = rent_nj$median_rent, linetype = "dashed", colour = "grey50") +
  geom_hline(yintercept = njgpa_nj$math_ready, linetype = "dashed", colour = "grey50") +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, colour = "grey40", linewidth = 0.7) +   # the least-squares line
  geom_point(size = 2.2) +
  geom_text(
    data = labeled,
    aes(label = short),
    hjust = 0,
    nudge_x = 25,
    size = 2.6
  ) +
  annotate(
    "text",
    x = rent_nj$median_rent + 15,
    y = 100,
    label = paste0("New Jersey: $", format(rent_nj$median_rent, big.mark = ",")),
    hjust = 0,
    size = 2.5,
    colour = "grey30"
  ) +
  annotate(
    "text",
    x = max(towns_merged$median_rent),
    y = njgpa_nj$math_ready - 3,
    label = paste0("New Jersey: ", njgpa_nj$math_ready, "%"),
    hjust = 1,
    size = 2.5,
    colour = "grey30"
  ) +
  scale_x_continuous(labels = scales::dollar, expand = expansion(mult = c(0.05, 0.1))) +   # room for "Princeton"
  scale_y_continuous(limits = c(0, 100)) +
  labs(
    title    = "Near TCNJ, every $100 more in rent comes with about 4 more points in math;\nBurlington township sits furthest above the line; only it and Florence beat the state for less rent",
    subtitle = "Each point is one of 19 towns within about 30 minutes of campus, given its high school district's result. Solid line: least squares.\nDashed lines: New Jersey. Towns in one regional district share a result (three pairs).",
    x        = "Median gross rent, 2020-2024 (per month)",
    y        = "11th graders graduation ready in math,\nNJGPA 2024-25 (percent)",
    caption  = "Sources: NJ Department of Education, School Performance Reports 2024-25, NJGPA (district rows, all students);\nU.S. Census Bureau, American Community Survey 2020-2024, table B25064.",
    # alt text does not show on the plot; a Shiny app can pass it to screen readers
    alt      = paste(
      "Scatterplot of 19 towns near TCNJ. The x-axis is median gross rent, 2020-2024; the y-axis is the percent",
      "of 11th graders graduation ready in math in the town's high school district, 2024-25. A least-squares",
      "line rises about 3.9 points for every $100 of rent. Dashed lines mark New Jersey: $1,720 and 58.5 percent.",
      "Burlington township ($1,326, 63.8 percent) sits furthest above the line, about 20 points, and Plainsboro",
      "next; Trenton ($1,294, 11.7 percent) sits furthest below it, about 31 points. Ewing ($1,679, 42.0 percent)",
      "is about 16 points below the line. Only Burlington township and Florence ($1,407, 59.0 percent) are above",
      "the state in math and below it in rent."
    )
  ) +
  theme(
    plot.title.position = "plot",                  # line the title up with the left edge of the figure
    plot.title = element_text(size = 10),
    plot.subtitle = element_text(size = 7.5),
    plot.caption = element_text(size = 6.5),
    axis.title = element_text(size = 8.5)
  )

fig1

# Git does not keep empty folders, so make output/figures if it is not there yet
dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)

ggsave(
  "output/figures/math_vs_rent.png",
  fig1,
  width = 7,
  height = 4.6,
  dpi = 300,
  bg = "white"
)




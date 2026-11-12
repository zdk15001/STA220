# STA 220, Activity 3.3a: Make the Case for One Bike Lane

Pine County can afford **one** protected bike lane. Four groups, four streets, one dataset that can
support any of them. Each group builds the figure that makes the best honest case for its street.

Data for Everyday Life: Data Ethics, Management, and Visualization. The College of New Jersey.

## For students

**The handout.** Follow the Activity 3.3a handout (print it; there is
room to write on every page). It has the steps and the times.

**Getting the files.** In GitHub Desktop, click **Fetch origin**, then **Pull origin**; this folder
appears next to `3.3`. Then double-click `3.3a_activity.Rproj`. You need the tidyverse and
sf, which you installed for 3.3. You do not need the internet.

**Your street.**

| Group | Street | Where |
|---|---|---|
| 1 | Market Street | Birch's downtown |
| 2 | Ridge Road | Alder to Birch, a fast country road |
| 3 | College Avenue | Elm, past Pine County College |
| 4 | Station Road | Dogwood, to the train station |

**Running the R parts.**

1. Open an example in `scripts/example_figures/` and run all of it (Ctrl+Shift+Enter, or
   Cmd+Shift+Return on a Mac), or open its picture in `output/figures/`.
2. Open `scripts/create_your_visualization_here.R`, set `my_corridor` to your street, and run it
   to load the bike data.
3. In your example, copy from `COPY FROM HERE` down to `STOP HERE`, and paste it under
   **Your Figure**. The top of what you pasted lists what to change for the bike data (`section`
   becomes `corridor`, `vehicles_per_day` becomes `bikes_per_day`, and so on). Change the title to
   your argument.

## The thirteen examples

Each example adds one or two things to the one before it. "New in the code" is what to look for.
Four of them are maps (3, 6, 11, and 13). They use only code from the workbooks (Module 2 through
2.3 for the data steps, 3.1 to 3.3 for the figures), plus one new function, `geom_bin_2d()`, in
Example 3.

| # | Script | The figure | New in the code | Makes this section look best | What it leaves out |
|---|---|---|---|---|---|
| 1 | `example_01_cost.R` | Cost of a new lane | `geom_col()` | Birch Straightaway | What the money buys |
| 2 | `example_02_traffic.R` | Cars per day, 2025, sorted | `filter()`, `fct_reorder()`, commas on the axis | Elm Bridge | Change over time; crashes |
| 3 | `example_03_crash_map.R` | **Map:** crashes in each half-mile square | `geom_sf()` layers, `geom_sf_text()`, `geom_bin_2d()` (a histogram in two directions) | Elm Bridge and Dogwood Curve | A count, not a rate: Elm has the most cars, too; the squares change if you change their size |
| 4 | `example_04_traffic_over_time.R` | Cars per day, 2016 to 2025 | `geom_line()`, a named colour for each section | Cedar Interchange | Elm still carries the most |
| 5 | `example_05_growth.R` | Percent change since 2016 | `pivot_wider()`, a percent change, `my_section` drawn on top in colour | Cedar Interchange | A percent hides where each section started |
| 6 | `example_06_traffic_map.R` | **Map:** line width is cars per day | `left_join()` onto the shapes, `linewidth` inside `aes()` | Elm Bridge | Widths are harder to compare than the bar lengths in Example 2 |
| 7 | `example_07_count_vs_rate.R` | Crashes as a count and as a rate | `group_by()` and `summarize()`, a rate, `pivot_longer()`, `facet_wrap()` | Elm Bridge (count), Dogwood Curve (rate) | Most Dogwood crashes are cars running off the curve, which a lane may not fix |
| 8 | `example_08_rush_hour.R` | Speed, hour by hour | one panel per section, a reference line from the data | Elm Bridge | The other 19 hours of the day |
| 9 | `example_09_severity.R` | Share of crashes by the worst injury | `geom_bar(position = "fill")`, colours by name | Dogwood Curve | Dogwood has the fewest cars |
| 10 | `example_10_tradeoffs.R` | Cost, homes, wetlands, years | `pivot_longer()` on four columns, free scales | Birch Straightaway | How small Birch's problem is |
| 11 | `example_11_growth_and_serious_map.R` | **Map:** growth as line width, serious crashes as dots | only some points (`filter()` before the layer) | Cedar Interchange and Dogwood Curve | Elm's rush hour; counts versus rates |
| 12 | `example_12_value.R` | Hours of delay per $1 million | three tables into one number with two `left_join()`s | Birch Straightaway | Elm has by far the most delay, and whether a lane removes delay at all |
| 13 | `example_13_town_rate_map.R` | **Map:** towns shaded by crashes per 1,000 residents | `count()` by town, a rate, a shaded town map | Dogwood Curve (Dogwood is the darkest town) | Most Parkway drivers do not live in the town they crash in; Fir is a small town, so a few crashes make a big rate; grey Alder means no Parkway, not no data |

`output/example_figures_all.pdf` has all thirteen, one per page, for handing out or sharing on the screen.

## Where did the data come from?

**Nowhere: everything here is made up.** Pine County is the made-up county from workbook 3.3 (the same
six rectangular towns). `scripts/01_make_data.R` invents two decisions in it, so that every option
is the best on some measures and the worst on others. It uses `set.seed()`, so it makes the same
numbers every time. You do not need to run it; everything it writes is already in `data/`.

| File | One row is | Used by |
|---|---|---|
| `pine_towns.gpkg` | a town (a rectangle): population and square miles | both |
| `bike_corridors.gpkg` | a street (a line): miles, cost, parking lost, trees removed, years to build, what it connects to | your figure |
| `bike_yearly.csv` | a street in a year, 2023 to 2025: months with a rider count, riders and cars per day, crashes, serious crashes | your figure |
| `bike_monthly.csv` | a street in a month, January 2023 to December 2025 | your figure |
| `bike_hourly.csv` | a street in an hour of an average weekday in 2025: riders per hour, car speed, speed limit | your figure |
| `bike_crashes.gpkg` | a crash involving a bike, 2023 to 2025 (a point): severity, type, town, and its x and y in miles | your figure |
| `highway_sections.gpkg` | a section of the Pine Parkway (a line): miles, cost, homes, wetlands, years to build | the examples |
| `highway_yearly.csv` | a section in a year, 2016 to 2025: vehicles per day, trucks, rush-hour delay, crashes | the examples |
| `highway_hourly.csv` | a section in an hour of an average weekday in 2025: vehicles per hour, speed, speed limit | the examples |
| `highway_crashes.gpkg` | a crash, 2021 to 2025 (a point): severity, type, town, and its x and y in miles | the examples |

Two things to notice, because real data have them too:

- **Missing data.** Station Road's bike counter went in in January 2024, so it has no rider counts
  for 2023 (`NA`), but it does have 2023 crashes and car counts.
- **Coordinates.** The shapes are in miles, so `st_length()` gives miles. A made-up map still needs a
  coordinate reference system, or R cannot stack the layers; this one is centered on a point in New
  Jersey's Pine Barrens.

## What is in each folder?

```
3.3a_activity/
  3.3a_activity.Rproj                     # double-click to open the project
  README.md                               # this file
  data/                                   # made by 01_make_data.R (all made up)
  scripts/
    create_your_visualization_here.R      # YOURS: loads the bike data, then a blank space for your figure
    example_figures/                      # the thirteen examples, simplest first (highway data)
      example_01_cost.R ... example_13_town_rate_map.R
    01_make_data.R                        # makes everything in data/ (you do not need to run it)
    master.R                              # reruns everything
  output/
    figures/                              # the thirteen example figures (and yours, if you save it)
    example_figures_all.pdf               # all thirteen, one per page
```

## Who made it, and when

Zachary D. Kline, The College of New Jersey, with help from Claude (Anthropic). Last updated
November 12, 2026. Tested with R 4.3.3, tidyverse 2.0.0 (ggplot2 3.4.4), and sf 1.0.15.

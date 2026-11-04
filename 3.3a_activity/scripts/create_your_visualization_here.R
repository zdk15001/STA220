# scripts/create_your_visualization_here.R
# Activity 3.3a: Make the case for one bike lane.
#
# Pine County can afford ONE protected bike lane. Your group argues for ONE street:
#   Group 1: Market Street    Group 2: Ridge Road    Group 3: College Avenue    Group 4: Station Road
#
# To Do: copy everything under The Figure (and any steps above it that make a table or do a merge) from your example. Paste it under Your Figure.


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

my_corridor <- "Market Street"           # CHANGE to your group's street (spelled exactly as above)

# One colour per street, if you want them
corridor_colours <- c(
  "Market Street"  = "#2a78d6",
  "Ridge Road"     = "#eb6834",
  "College Avenue" = "#1baf7a",
  "Station Road"   = "#eda100"
)

# One colour per severity, darker red is more severe (Example 9 uses these)
severity_colours <- c(
  "serious or fatal" = "#a50f15",
  "injury"           = "#fb6a4a",
  "no injury"        = "#fcbba1"
)

# The six towns of Pine County (a map background). One row is one town. Expect 6 rows and 5 columns
pine_towns <- read_sf("data/pine_towns.gpkg")

dim(pine_towns)
names(pine_towns)
summary(pine_towns)

# One row is one street, with its shape (a line). Expect 4 rows and 10 columns
bike_corridors <- read_sf("data/bike_corridors.gpkg")

dim(bike_corridors)
names(bike_corridors)
summary(bike_corridors)

# One row is one street in one year, 2023 to 2025. Expect 12 rows and 7 columns.
# Station Road's bike counter went in in January 2024, so its 2023 bikes_per_day is NA.
bike_yearly <- read_csv("data/bike_yearly.csv")

dim(bike_yearly)
names(bike_yearly)
summary(bike_yearly)

# One row is one street in one month, January 2023 to December 2025. Expect 144 rows and 6 columns
# (12 NA in bikes_per_day: Station Road in 2023)
bike_monthly <- read_csv("data/bike_monthly.csv")

dim(bike_monthly)
names(bike_monthly)
summary(bike_monthly)

# One row is one street in one hour of an average weekday in 2025. Expect 96 rows and 5 columns
bike_hourly <- read_csv("data/bike_hourly.csv")

dim(bike_hourly)
names(bike_hourly)
summary(bike_hourly)

# One row is one crash involving a bike, 2023 to 2025, with where it happened (a point).
# Expect 111 rows and 10 columns (town, x, and y say where it happened)
bike_crashes <- read_sf("data/bike_crashes.gpkg")

dim(bike_crashes)
names(bike_crashes)
summary(bike_crashes)


# The Key (Use this to compare Highway to Bikes!) ------------------------------------------------

#   In the examples                        In your data
#   highway_sections (one line each)       bike_corridors
#   highway_yearly (2016 to 2025)          bike_yearly (2023 to 2025), or bike_monthly for months
#   highway_hourly                         bike_hourly
#   highway_crashes (one point each)       bike_crashes
#   section, my_section, section_colours   corridor, my_corridor, corridor_colours
#   vehicles_per_day                       bikes_per_day (riders) or cars_per_day
#   vehicles_per_hour                      bikes_per_hour
#   avg_speed_mph, speed_limit             car_speed_mph, speed_limit
#   rush_delay_min, truck_pct              (nothing like them; try bikes_per_day or cars_per_day)
#   crashes, serious_crashes               crashes, serious_crashes
#   severity                               severity (the same three levels)
#   crash_type                             crash_type: dooring, turning car, passing car, other
#   town, x, y (on each crash)             town, x, y
#   cost_million, years_to_build           cost_million, years_to_build
#   homes_affected, wetland_acres          parking_lost, trees_removed
#   miles                                  miles
#   (not in the highway data)              connects_to, counted_since, months_counted
#
#   Examples 5 and 11: names_prefix = "vehicles_" makes vehicles_2016 to vehicles_2025. Yours can be
#   names_prefix = "bikes_", which makes bikes_2023 to bikes_2025. Station Road has no 2023 count,
#   so its 2023 to 2025 change is NA, and both examples stop with an error. Use 2024 to 2025
#   (bikes_2024 in place of bikes_2023), or add filter(!is.na(pct_change)) to the end of growth
#   (Example 5) or sections_growth (Example 11) and say on the figure why Station Road is missing.
#
#   Examples 5, 10, and 12 draw my_section again on top (the table called mine) in its own colour.
#   Use filter(corridor == my_corridor), and your street's colour from corridor_colours above.
#
#   A rate for bikes: crashes per 100,000 bike trips = crashes / (bikes_per_day x 365) x 100000
#   (drop the years with no count first: filter(!is.na(bikes_per_day)))
#
#   Remember to change the title, the axis labels, and the caption to fit your figure and your argument.


# Hints ------------------------------------------------------------------------------------------
#   1. Check that you loaded the data by running the script above!
#   2. Highlight a word and other matching words will be highlighted.
#   3. Run your code one step at a time (or one pipe at a time)
#   4. A few examples need some hints:
#        Example 3    the streets are short, so try binwidth = 0.25
#        Example 7    use the bike rate in The Key (crashes per 100,000 bike trips)
#        Example 8    there is no bike speed: use car_speed_mph (keep geom_hline()), or
#                     bikes_per_hour (and delete the geom_hline() line)
#        Example 9    for Market Street, try fill = crash_type in place of severity, and delete
#                     the scale_fill_manual() line (its colours only name the severity levels)
#        Example 12   there is no rush-hour delay for bikes: divide something else by
#                     cost_million (riders per $1 million, or crashes per $1 million)
#        Example 13   the hardest one: count(town) works on bike_crashes too, and Cedar and Fir
#                     (none of the four streets) come out grey
#   5. To show your figure to the class, click Zoom above the plot (or Export > Save as Image).


# Your Figure ------------------------------------------------------------------------------------

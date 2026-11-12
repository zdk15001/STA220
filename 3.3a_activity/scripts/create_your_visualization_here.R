# scripts/create_your_visualization_here.R
# Activity 3.3a: Make the case for one bike lane.
#
# Pine County can afford ONE protected bike lane. Your group argues for ONE street:
#   Group 1: Market Street    Group 2: Ridge Road    Group 3: College Avenue    Group 4: Station Road
#
# To Do: open your example and copy from COPY FROM HERE down to STOP HERE. Paste it under
# Your Figure (at the bottom of this script). Then make the changes listed at the top of what you
# pasted.


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


# Hints ------------------------------------------------------------------------------------------
#   1. Check that you loaded the data by running the script above!
#   2. Each example says what to change for the bike data, right under COPY FROM HERE.
#   3. Highlight a word and other matching words will be highlighted.
#   4. Run your code one step at a time (or one pipe at a time)
#   5. The "Expect" comments in an example are about the highway data. Your numbers will differ!
#   6. Remember to change the title, the axis labels, and the caption to fit your figure and your
#      argument.
#   7. To show your figure to the class, click Zoom above the plot (or Export > Save as Image).


# Your Figure ------------------------------------------------------------------------------------

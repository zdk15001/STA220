# scripts/01_make_data.R
# Makes every table in data/ for Activity 3.3a. EVERYTHING HERE IS MADE UP.

# NOTE: You do NOT need to run this. Everything it writes is already in data/. It also uses some
# commands I did not cover in class.


# Packages ---------------------------------------------------------------------------------------

library(tidyverse)
library(sf)

set.seed(123)          # Ensures the same "random" numbers every time

# Even a made-up map needs a coordinate reference system, or R cannot stack the layers.
# This one measures in miles from a point in New Jersey's Pine Barrens.
pine_crs <- "+proj=tmerc +lat_0=39.75 +lon_0=-74.65 +units=mi"

# Points in order become shapes: a line (a road) or a polygon (a town) for each name
make_shapes <- function(points, type) {
  points |>
    st_as_sf(coords = c("x", "y"), crs = pine_crs) |>
    group_by(name) |>
    summarize(do_union = FALSE) |>                  # keep the points in order
    st_cast("LINESTRING") |>
    st_cast(type)
}

# Put each crash on its road. Each piece of road (between two points) gets the same share of
# crashes, so short pieces get crowded: that is how crashes bunch up.
place_crashes <- function(crashes, points, nudge) {
  pieces <- points |>
    group_by(name) |>
    mutate(x_end = lead(x), y_end = lead(y)) |>      # lead() is the next point
    filter(!is.na(x_end)) |>
    mutate(piece = row_number(), n_pieces = n()) |>
    ungroup()

  crashes |>
    left_join(distinct(pieces, name, n_pieces), by = "name") |>
    mutate(piece = ceiling(runif(n()) * n_pieces)) |>
    left_join(pieces, by = c("name", "piece", "n_pieces")) |>
    mutate(
      along = runif(n()),                                     # 0 = start of the piece, 1 = end
      x = x + along * (x_end - x) + rnorm(n(), 0, nudge),
      y = y + along * (y_end - y) + rnorm(n(), 0, nudge)
    ) |>
    st_as_sf(coords = c("x", "y"), crs = pine_crs, remove = FALSE)   # keep x and y as columns too
}

# A bell-shaped bump centered on an hour (for the hourly tables)
bump <- function(hour, centre, width) {
  exp(-((hour - centre)^2) / (2 * width^2))
}


# Pine County: The Six Towns ---------------------------------------------------------------------

towns <- tribble(
  ~town_code, ~town,      ~xmin, ~xmax, ~ymin, ~ymax, ~pop,
  "01",       "Alder",        0,     6,     5,     9,  6000,
  "02",       "Birch",        6,    10,   6.5,     9, 18000,
  "03",       "Cedar",        6,    10,     5,   6.5, 12000,
  "04",       "Dogwood",      0,     3,     0,     5,  9000,
  "05",       "Elm",          3,     5,     0,     5, 21000,
  "06",       "Fir",          5,    10,     0,     5,  4000
) |>
  mutate(
    name = town,
    sq_miles = (xmax - xmin) * (ymax - ymin),
    label_x = xmin + 0.15,                          # where the town's name goes on a map
    label_y = ymax - 0.15
  )

# A rectangle is drawn using five points where the last point closes the shape
corners <- bind_rows(
  mutate(towns, x = xmin, y = ymin),
  mutate(towns, x = xmax, y = ymin),
  mutate(towns, x = xmax, y = ymax),
  mutate(towns, x = xmin, y = ymax),
  mutate(towns, x = xmin, y = ymin)
)

pine_towns <- make_shapes(corners, "POLYGON") |>
  left_join(towns, by = "name") |>
  select(town_code, town, pop, sq_miles)


# The Bike Lane: Four Streets --------------------------------------------------------------------

# The points each street runs through, in order (in miles)
bike_points <- bind_rows(
  tibble(name = "Market Street",  x = c(7.4, 8.6),      y = c(7.75, 7.8)),
  tibble(name = "Ridge Road",     x = c(3.0, 4.5, 6.5), y = c(8.3, 8.6, 8.2)),
  tibble(name = "College Avenue", x = c(3.6, 4.4),      y = c(0.5, 2.0)),
  tibble(name = "Station Road",   x = c(0.9, 1.6, 2.2), y = c(3.3, 3.7, 4.3))
)

# label_x and label_y: a spot next to each street for its name on a map
bike_facts <- tribble(
  ~corridor,        ~towns,            ~cost_million, ~parking_lost, ~trees_removed, ~years_to_build, ~connects_to,                               ~counted_since, ~label_x, ~label_y,
  "Market Street",  "Birch",           2.4,           48,            0,              1.0,             "Birch's downtown shops and restaurants",   "2023-01",      8.0,      7.35,
  "Ridge Road",     "Alder and Birch", 4.9,           0,             115,            2.0,             "Alder's farms and the Pine Ridge trail",   "2023-01",      4.6,      7.95,
  "College Avenue", "Elm",             2.6,           31,            6,              1.0,             "Pine County College and Elm's apartments", "2023-01",      4.0,      2.9,
  "Station Road",   "Dogwood",         0.6,           4,             0,              0.5,             "Dogwood's train station",                  "2024-01",      1.9,      3.05
)

bike_corridors <- make_shapes(bike_points, "LINESTRING") |>
  rename(corridor = name) |>
  mutate(miles = round(as.numeric(st_length(geometry)), 2)) |>
  left_join(bike_facts, by = "corridor") |>
  select(corridor, towns, miles, cost_million, parking_lost, trees_removed, years_to_build, connects_to, counted_since)


# The Bike Lane: Each Month, 2023 to 2025 --------------------------------------------------------

# Riders per day in the first January counted, growth per year, cars per day, crashes per 100,000 trips.
# Station Road's counter went in in January 2024 (first_year).
bike_settings <- tribble(
  ~corridor,        ~first_year, ~bikes_start, ~growth, ~cars, ~crash_rate,
  "Market Street",  2023,        175,          0.03,    14500, 30,
  "Ridge Road",     2023,         34,          0.00,     6800, 60,
  "College Avenue", 2023,        440,          0.17,     9200,  3.5,
  "Station Road",   2024,        110,          0.45,     7400,  6
)

# How busy each month is (1 = an average month)
season <- tribble(
  ~month_num, ~`Market Street`, ~`Ridge Road`, ~`College Avenue`, ~`Station Road`,
   1,          0.65,             0.35,          0.70,              0.80,
   2,          0.70,             0.40,          1.00,              0.85,
   3,          0.85,             0.70,          1.10,              0.95,
   4,          1.00,             1.00,          1.15,              1.00,
   5,          1.15,             1.40,          1.05,              1.10,
   6,          1.25,             1.70,          0.45,              1.10,
   7,          1.30,             1.90,          0.40,              1.05,
   8,          1.25,             1.80,          0.55,              1.05,
   9,          1.15,             1.40,          1.15,              1.10,
  10,          1.00,             0.90,          1.15,              1.05,
  11,          0.80,             0.50,          1.05,              0.95,
  12,          0.70,             0.35,          0.75,              0.85
) |>
  pivot_longer(-month_num, names_to = "corridor", values_to = "season")

# rnorm() adds a little noise; rpois() draws a random whole number of crashes
bike_months <- expand_grid(corridor = bike_settings$corridor, year = 2023:2025, month_num = 1:12) |>
  left_join(bike_settings, by = "corridor") |>
  left_join(season, by = c("corridor", "month_num")) |>
  mutate(
    month = make_date(year, month_num, 1),
    years_in = year - first_year + (month_num - 1) / 12,
    bikes = bikes_start * (1 + growth)^years_in * season * rnorm(n(), 1, 0.05),
    bikes_per_day = if_else(year < first_year, NA, round(bikes)),          # no counter yet
    cars_per_day = round(cars * (0.9 + 0.1 * season) * rnorm(n(), 1, 0.02), -1),
    crashes = rpois(n(), crash_rate * bikes * 30 / 100000)
  )

bike_monthly <- bike_months |>
  select(corridor, month, year, bikes_per_day, cars_per_day, crashes)


# The Bike Lane: Every Crash ---------------------------------------------------------------------

# Shares of each street's crashes: how serious, and what kind
bike_crash_settings <- tribble(
  ~name,            ~serious, ~injury, ~dooring, ~turning, ~passing,
  "Market Street",  0.07,     0.70,    0.45,     0.25,     0.15,
  "Ridge Road",     0.40,     0.50,    0.00,     0.10,     0.60,
  "College Avenue", 0.05,     0.60,    0.15,     0.45,     0.15,
  "Station Road",   0.07,     0.63,    0.05,     0.35,     0.30
)

# uncount() repeats each month's row once per crash, so one row is one crash
bike_crashes <- bike_months |>
  select(name = corridor, year, month_num, crashes) |>
  uncount(crashes) |>
  left_join(bike_crash_settings, by = "name") |>
  mutate(
    roll = runif(n()),
    severity = case_when(
      roll < serious ~ "serious or fatal",
      roll < serious + injury ~ "injury",
      .default = "no injury"
    ),
    roll = runif(n()),
    crash_type = case_when(
      roll < dooring ~ "dooring",
      roll < dooring + turning ~ "turning car",
      roll < dooring + turning + passing ~ "passing car",
      .default = "other"
    ),
    date = make_date(year, month_num, sample(1:28, n(), replace = TRUE))
  ) |>
  place_crashes(bike_points, nudge = 0.02) |>
  st_join(select(pine_towns, town)) |>               # the town each crash is in
  arrange(date) |>
  mutate(crash_id = row_number()) |>
  select(crash_id, corridor = name, date, year, severity, crash_type, town, x, y)

# One row per street per year. Station Road's 2023 bikes_per_day is NA (no counter yet).
bike_yearly <- bike_monthly |>
  group_by(corridor, year) |>
  summarize(
    months_counted = sum(!is.na(bikes_per_day)),
    bikes_per_day = round(mean(bikes_per_day)),
    cars_per_day = round(mean(cars_per_day), -1),
    crashes = sum(crashes),
    .groups = "drop"
  ) |>
  left_join(
    bike_crashes |>
      st_drop_geometry() |>
      count(corridor, year, wt = severity == "serious or fatal", name = "serious_crashes"),
    by = c("corridor", "year")
  ) |>
  mutate(serious_crashes = replace_na(serious_crashes, 0))


# The Bike Lane: An Average Weekday in 2025 ------------------------------------------------------

bike_hourly <- expand_grid(corridor = bike_settings$corridor, hour = 0:23) |>
  left_join(filter(bike_yearly, year == 2025), by = "corridor") |>
  mutate(
    when = case_when(                                  # when people ride
      corridor == "Market Street"  ~ 0.08 + 0.5 * bump(hour, 8, 1.2) + bump(hour, 12.5, 1.5) + bump(hour, 18, 1.8),
      corridor == "Ridge Road"     ~ 0.03 + bump(hour, 6.5, 1) + 0.9 * bump(hour, 17.5, 1.5),
      corridor == "College Avenue" ~ 0.05 + bump(hour, 9, 1.3) + 0.8 * bump(hour, 13, 2) + 0.7 * bump(hour, 16.5, 1.5),
      corridor == "Station Road"   ~ 0.04 + bump(hour, 6.8, 0.9) + 0.9 * bump(hour, 17.8, 1)
    ),
    speed_limit = case_when(corridor == "Ridge Road" ~ 40, corridor == "Station Road" ~ 30, .default = 25),
    night = bump(hour, 2, 3) + bump(hour, 26, 3),       # cars go fastest late at night
    car_speed_mph = case_when(
      corridor == "Market Street"  ~ 21 + 9 * night,
      corridor == "Ridge Road"     ~ 47 + 7 * night,
      corridor == "College Avenue" ~ 26 + 8 * night,
      corridor == "Station Road"   ~ 32 + 7 * night
    ),
    car_speed_mph = round(car_speed_mph + rnorm(n(), 0, 0.6))
  ) |>
  group_by(corridor) |>
  mutate(bikes_per_hour = round(bikes_per_day * when / sum(when))) |>
  ungroup() |>
  select(corridor, hour, bikes_per_hour, car_speed_mph, speed_limit)


# The Highway Lane: Four Sections of the Pine Parkway --------------------------------------------

# The points each section runs through, in order. More points where crashes bunch up (the middle
# of Dogwood Curve and the bridge on Elm Bridge).
highway_points <- bind_rows(
  tibble(name = "Dogwood Curve",      x = c(0.8, 1.5, 2.0, 2.15, 2.3, 2.45, 3.0), y = c(1.4, 1.5, 1.75, 1.85, 1.97, 2.12, 2.8)),
  tibble(name = "Elm Bridge",         x = c(3.0, 3.8, 4.2, 5.0),                  y = c(2.8, 3.08, 3.24, 3.6)),
  tibble(name = "Cedar Interchange",  x = c(5.0, 6.0, 6.8, 7.3),                  y = c(3.6, 4.4, 5.2, 5.8)),
  tibble(name = "Birch Straightaway", x = c(7.3, 10.0),                           y = c(5.8, 8.6))
)

highway_facts <- tribble(
  ~section,             ~exits,      ~towns,            ~cost_million, ~homes_affected, ~wetland_acres, ~years_to_build, ~label_x, ~label_y,
  "Dogwood Curve",      "Exits 1-2", "Dogwood",         38,            4,               11.5,           3.0,             1.9,      0.85,
  "Elm Bridge",         "Exits 2-3", "Elm",             96,            37,              0.8,            4.5,             4.1,      2.3,
  "Cedar Interchange",  "Exits 3-4", "Fir and Cedar",   54,            9,               3.2,            3.0,             7.6,      4.1,
  "Birch Straightaway", "Exits 4-5", "Cedar and Birch", 19,            0,               0.0,            1.5,             9.15,     6.25
)

highway_sections <- make_shapes(highway_points, "LINESTRING") |>
  rename(section = name) |>
  mutate(miles = round(as.numeric(st_length(geometry)), 2)) |>
  left_join(highway_facts, by = "section") |>
  select(section, exits, towns, miles, cost_million, homes_affected, wetland_acres, years_to_build)


# The Highway Lane: Each Year, 2016 to 2025 ------------------------------------------------------

# Traffic grows in a straight line, except Cedar Interchange (flat until its warehouses opened).
# Everything dips in 2020. crash_rate is crashes per 100 million vehicle-miles.
highway_settings <- tribble(
  ~section,             ~grows_from, ~vehicles_2016, ~vehicles_2025, ~delay_2016, ~delay_2025, ~trucks_2016, ~trucks_2025, ~crash_rate,
  "Dogwood Curve",      2016,        34000,          36000,          2.0,          2.6,         6.0,          6.5,         275,
  "Elm Bridge",         2016,        76000,          82000,          8.5,         11.5,         7.0,          7.5,         185,
  "Cedar Interchange",  2018,        41000,          68000,          1.2,          6.4,         8.0,         21.0,          70,
  "Birch Straightaway", 2016,        50000,          54500,          3.2,          4.1,         9.0,          9.5,          60
)

highway_years <- expand_grid(section = highway_settings$section, year = 2016:2025) |>
  left_join(highway_settings, by = "section") |>
  left_join(st_drop_geometry(highway_sections), by = "section") |>
  mutate(
    progress = pmax(0, (year - grows_from) / (2025 - grows_from)),       # 0 at the start, 1 in 2025
    dip = if_else(year == 2020, 0.85, 1),
    vehicles_per_day = round((vehicles_2016 + (vehicles_2025 - vehicles_2016) * progress) * dip * rnorm(n(), 1, 0.012), -2),
    rush_delay_min = round((delay_2016 + (delay_2025 - delay_2016) * progress) * if_else(year == 2020, 0.55, 1) + rnorm(n(), 0, 0.12), 1),
    truck_pct = round(trucks_2016 + (trucks_2025 - trucks_2016) * progress + rnorm(n(), 0, 0.25), 1),
    crashes = rpois(n(), crash_rate * vehicles_per_day * 365 * miles / 100000000)
  )


# The Highway Lane: Every Crash ------------------------------------------------------------------

highway_crash_settings <- tribble(
  ~name,                ~serious, ~injury, ~rear_end, ~lane_change, ~off_road,
  "Dogwood Curve",      0.11,     0.34,    0.15,      0.15,         0.50,
  "Elm Bridge",         0.03,     0.23,    0.60,      0.20,         0.05,
  "Cedar Interchange",  0.06,     0.28,    0.30,      0.40,         0.10,
  "Birch Straightaway", 0.05,     0.26,    0.35,      0.30,         0.10
)

# One row per crash in every year (the yearly counts come from these), placed on the road
highway_crashes_all <- highway_years |>
  select(name = section, year, crashes) |>
  uncount(crashes) |>
  left_join(highway_crash_settings, by = "name") |>
  mutate(
    roll = runif(n()),
    severity = case_when(
      roll < serious ~ "serious or fatal",
      roll < serious + injury ~ "injury",
      .default = "no injury"
    ),
    roll = runif(n()),
    crash_type = case_when(
      roll < rear_end ~ "rear-end",
      roll < rear_end + lane_change ~ "lane change",
      roll < rear_end + lane_change + off_road ~ "ran off road",
      .default = "other"
    ),
    date = make_date(year, sample(1:12, n(), replace = TRUE), sample(1:28, n(), replace = TRUE))
  ) |>
  place_crashes(highway_points, nudge = 0.03) |>
  arrange(date) |>
  select(section = name, date, year, severity, crash_type, x, y)

highway_yearly <- highway_years |>
  left_join(
    highway_crashes_all |>
      st_drop_geometry() |>
      count(section, year, wt = severity == "serious or fatal", name = "serious_crashes"),
    by = c("section", "year")
  ) |>
  select(section, year, vehicles_per_day, truck_pct, rush_delay_min, crashes, serious_crashes)

# The map only shows the last five years
highway_crashes <- highway_crashes_all |>
  filter(year >= 2021) |>
  st_join(select(pine_towns, town)) |>               # the town each crash is in (NA past the county line)
  mutate(crash_id = row_number()) |>
  select(crash_id, section, date, year, severity, crash_type, town, x, y)


# The Highway Lane: An Average Weekday in 2025 ---------------------------------------------------

highway_hourly <- expand_grid(section = highway_settings$section, hour = 0:23) |>
  left_join(filter(highway_yearly, year == 2025), by = "section") |>
  mutate(
    when = 0.15 + bump(hour, 7.8, 1.4) + 1.1 * bump(hour, 17.2, 1.6) + 0.45 * bump(hour, 12.5, 2.5),
    when = if_else(section == "Cedar Interchange", when + 0.6 * bump(hour, 6, 0.6) + 0.6 * bump(hour, 14, 0.6) + 0.5 * bump(hour, 22, 0.6), when),
    speed_limit = if_else(section == "Dogwood Curve", 50, 65),
    avg_speed_mph = case_when(              # rush hour slows each section down by a different amount
      section == "Dogwood Curve"      ~ 49 - 5 * bump(hour, 7.8, 1) - 6 * bump(hour, 17.2, 1.2),
      section == "Elm Bridge"         ~ 62 - 38 * bump(hour, 7.8, 1) - 41 * bump(hour, 17.3, 1.3),
      section == "Cedar Interchange"  ~ 63 - 17 * bump(hour, 6, 0.7) - 15 * bump(hour, 14, 0.7) - 12 * bump(hour, 22, 0.7) - 10 * bump(hour, 17.2, 1),
      section == "Birch Straightaway" ~ 64 - 18 * bump(hour, 7.8, 1) - 21 * bump(hour, 17.3, 1.2)
    ),
    avg_speed_mph = round(avg_speed_mph + rnorm(n(), 0, 0.6))
  ) |>
  group_by(section) |>
  mutate(vehicles_per_hour = round(vehicles_per_day * when / sum(when), -1)) |>
  ungroup() |>
  select(section, hour, vehicles_per_hour, avg_speed_mph, speed_limit)


# Save -------------------------------------------------------------------------------------------

# Shapes go in GeoPackages (.gpkg), like workbook 3.3; tables without shapes go in CSVs
st_write(pine_towns, "data/pine_towns.gpkg", delete_dsn = TRUE, quiet = TRUE)

st_write(bike_corridors, "data/bike_corridors.gpkg", delete_dsn = TRUE, quiet = TRUE)

st_write(bike_crashes, "data/bike_crashes.gpkg", delete_dsn = TRUE, quiet = TRUE)

write_csv(bike_monthly, "data/bike_monthly.csv")

write_csv(bike_yearly, "data/bike_yearly.csv")

write_csv(bike_hourly, "data/bike_hourly.csv")

st_write(highway_sections, "data/highway_sections.gpkg", delete_dsn = TRUE, quiet = TRUE)

st_write(highway_crashes, "data/highway_crashes.gpkg", delete_dsn = TRUE, quiet = TRUE)

write_csv(highway_yearly, "data/highway_yearly.csv")

write_csv(highway_hourly, "data/highway_hourly.csv")

list.files("data")

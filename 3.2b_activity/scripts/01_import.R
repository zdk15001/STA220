# scripts/01_import.R
# Reads two sources from the files in data/ and writes one clean CSV for each.
#
#   Source 1: U.S. Census Bureau, American Community Survey 2020-2024 (5-year), table B25064, Median
#             Gross Rent, for New Jersey and every New Jersey town (county subdivision). Downloaded
#             from data.census.gov on October 28, 2026.
#             In:  data/ACSDT5Y2024.B25064-Data.csv (from the download's zip, unchanged)
#             Out: data/rent_clean.csv, one row per town
#                  data/rent_clean_nj.csv, one row: New Jersey
#
#   Source 2: NJ Department of Education, School Performance Reports 2024-2025, NJGPA table.
#             In:  data/njdoe_njgpa_all_students.csv (cut by hand from the Department's 119 MB
#                  Excel file, which is too big for GitHub; the README lists every step)
#                  https://www.nj.gov/education/spr/download/ - select district/state performance reports database in excel
#             Out: data/njgpa_clean.csv, one row per school district in 2024-25
#                  data/njgpa_clean_nj.csv, one row: New Jersey (the State row) in 2024-25
#
# NOTE: You do NOT need to learn every command in this script. 3.2b starts AFTER this script:
# it is "done," and 02_merge.R only reads the clean files it writes.
#
# All of these tasks can be done manually.


# Packages ---------------------------------------------------------------------------------------

library(tidyverse)


# Source 1: ACS, Median Gross Rent ---------------------------------------------------------------


rent_raw <- read_csv(
  "data/ACSDT5Y2024.B25064-Data.csv",
  skip = 2,                                                      # Skips the two header rows
  col_names = c("geo_id", "name", "median_rent", "rent_moe"),    # rename the first four columns
  col_select = 1:4,                                              # Select the first four columns
  col_types = cols(.default = col_character()),                  # Set default column to character
  na = c("", "-", "**", "***")                                   # turns cells containing blanks, "-", "**", and "***" into NA
)

# New jersey average shouldn't be here
rent_raw_nj <- filter(rent_raw, name == "New Jersey")

rent_raw <- filter(rent_raw, name != "New Jersey")

# One row is one place: every county subdivision. Expect 569 rows and 4 columns.
# Expect all variable types are character
dim(rent_raw)
names(rent_raw)
summary(rent_raw)

# New Jersey is intact expect 4 variables with 1 observation
# all variables should be characters
dim(rent_raw_nj)
names(rent_raw_nj)
summary(rent_raw_nj)


# Clean geo_id, rent, and rent margin of error
rent_clean <- rent_raw |>
  filter(!str_detect(name, "not defined")) |>                      # drop the 5 "County subdivisions not defined" rows
  mutate(
    geo_id = str_remove(geo_id, "0600000US"),                      # Remove 0600000 which tell us county subdivision
    rent_top_coded = median_rent == "3,500+",                      # identifies $3500 cell as the top code
    median_rent = as.numeric(str_remove_all(median_rent, "[,+]")), # remove all strings from median rent, including the + for top code, and turns numeric
    rent_moe = as.numeric(rent_moe)
  )

# Clean for nj (different geo id)
rent_clean_nj <- rent_raw_nj |>
  mutate(
    geo_id = str_remove(geo_id, "0400000US"),
    median_rent = as.numeric(median_rent),
    rent_moe = as.numeric(rent_moe)
  )

# One row is one town (expect 564). 5 variables (top coded is new!)
dim(rent_clean)
names(rent_clean)
summary(rent_clean)

# expect 1 row and 4 columns
dim(rent_clean_nj)
names(rent_clean_nj)
summary(rent_clean_nj)

# the key check: 0 rows means geo_id is a key
rent_clean |>
  count(geo_id) |>
  filter(n > 1)


# Source 2: NJ DOE, NJGPA ------------------------------------------------------------------------


njgpa_raw <- read_csv(
  "data/njgpa_district_2024_allstudent.csv",
  col_types = cols(.default = col_character())                   # every column as text (keeps leading zeros and percents)
)

# New Jersey (the "State" row) shouldn't be here
njgpa_raw_nj <- filter(njgpa_raw, DistrictCode == "State")

njgpa_raw <- filter(njgpa_raw, DistrictCode != "State")

# One row is one district in one school year, all students. Expect 960 rows (320 x 3 school years)
# and 14 columns. Expect all variable types are character
dim(njgpa_raw)
names(njgpa_raw)
summary(njgpa_raw)

# New Jersey is intact: expect 3 rows (one per school year) and 14 columns
# all variables should be characters
dim(njgpa_raw_nj)
names(njgpa_raw_nj)
summary(njgpa_raw_nj)


# Clean district code, names, and the percent graduation ready
njgpa_clean <- njgpa_raw |>
  filter(SchoolYear == "2024-25") |>                                                  # keep only 2024-25
  mutate(
    math_ready = as.numeric(str_remove(MathGraduationReadyPct_District, "%")),       # remove the % and turn numeric 
    ela_ready = as.numeric(str_remove(ELAGraduationReadyPct_District, "%"))
  ) |>
  select(
    district_code = DistrictCode,                                                     # rename while selecting
    district = DistrictName,
    district_county = CountyName,
    math_ready,
    ela_ready
  )

# Clean for nj (its percents are in the _State columns, not the _District columns)
njgpa_clean_nj <- njgpa_raw_nj |>
  filter(SchoolYear == "2024-25") |>
  mutate(
    math_ready = as.numeric(str_remove(MathGraduationReadyPct_State, "%")),
    ela_ready = as.numeric(str_remove(ELAGraduationReadyPct_State, "%"))
  ) |>
  select(
    district_code = DistrictCode,
    district = DistrictName,
    math_ready,
    ela_ready
  )

# One row is one district in 2024-25 (expect 320). 5 variables, and no NA in math_ready or ela_ready
dim(njgpa_clean)
names(njgpa_clean)
summary(njgpa_clean)

# expect 1 row and 4 columns: 58.5 percent graduation ready in math, 81.3 in ELA
dim(njgpa_clean_nj)
names(njgpa_clean_nj)
summary(njgpa_clean_nj)

# the key check: 0 rows means district_code is a key
njgpa_clean |>
  count(district_code) |>
  filter(n > 1)


# Save -------------------------------------------------------------------------------------------

write_csv(rent_clean, "data/rent_clean.csv")

write_csv(rent_clean_nj, "data/rent_clean_nj.csv")

write_csv(njgpa_clean, "data/njgpa_clean.csv")

write_csv(njgpa_clean_nj, "data/njgpa_clean_nj.csv")

# scripts/02_merge.R
# Puts my two clean sources together 
# (New Jersey, the benchmark, has its own files from 01_import.R; 03 reads them.)


# Packages and Load the Data ------------------------------------------------------------

library(tidyverse)

# Source 1, made by 01_import.R. geo_id is a code, so it is read as text.
rent <- read_csv(
  "data/rent_clean.csv",
  col_types = cols(geo_id = col_character())
)

# One row is one NJ town. Expect 564 rows and 5 columns.
dim(rent)
names(rent)
summary(rent)

# Source 2, made by 01_import.R. district_code is a code ("0475"), so it is read as text.
districts <- read_csv(
  "data/njgpa_clean.csv",
  col_types = cols(district_code = col_character())
)

# One row is one school district in 2024-25. Expect 320 rows and 5 columns.
dim(districts)
names(districts)
summary(districts)


# Know Your Key (Step 2) -------------------------------------------------------------------------

# 0 rows: geo_id is a key in rent
rent |>
  count(geo_id) |>
  filter(n > 1)

# 0 rows: district_code is a key in districts
districts |>
  count(district_code) |>
  filter(n > 1)


# Can These Be Merged? (Step 3) ------------------------------------------------------------------
# My answers to the five questions, copied from Step 6 of Build your Repository:
#
#   Unit of analysis  Not the same. A row of rent is a town; a row of districts is a school
#                     district. Most towns here have their own district, but some share one:
#                     East Windsor and Hightstown (East Windsor Regional), West Windsor and
#                     Plainsboro (West Windsor-Plainsboro Regional), and Chesterfield and Mansfield
#                     (Northern Burlington County Regional, grades 7 to 12). Towns that share a
#                     district will get the same NJGPA result.
#   Time              NJGPA: school year 2024-25 (11th graders tested in spring 2025).
#                     ACS: 2020-2024. Close, but not the same; the caption says both.
#   Key               None in common. rent has the Census code (geo_id); districts has the
#                     Department's district code. And the town's name is not a key: New Jersey has
#                     two Hamilton townships, two Hopewell townships, two Lawrence townships, and
#                     two Mansfield townships, and one of each pair is on my dashboard.
#   Format            geo_id is a 10-digit code, read as text in rent and typed as text below.
#                     district_code keeps its leading zero ("0475") in both.
#   Coverage          rent has every town in New Jersey; my dashboard uses 19 of them. All 19
#                     should find a row in rent and a row in districts.
#
#   Verdict           Merge after a fix.
#   The fix           A lookup table, written below: the 19 towns, each with its Census code and
#                     its high school district's code. It is the left table, because these 19
#                     towns are the rows the dashboard is about.


# The Fix: A Lookup Table (Step 4) ---------------------------------------------------------------

# Create a tribble with one row for each town in our dashboard and the associated key for rent and districts
# I did this manually in excel and then transferred my work over to a Tribble here

# 1) I identified all towns within 30 minutes of TCNJ (done in previous scripts) and copied the town variable and the geo_id to a new sheet
# 2) I identified the corresponding high school to each town manually (mostly through Google).
#    The vast majority were confirmed with a Wikipedia search.
#    In addition to Google, I double checked the grades offered and looked for potential towns with comparable names. 
# 3) Lastly, I prompted Claude AI to look for problems with this matching and my logic for doing so. 

# Note: We will go over some more tools on Monday that can help with this :)

# Note: This is a limitation! Some of these districts may cover townships outside of the district and some of these
# towns may feed into multiple districts (e.g., Northern Burlington County Regional)
dashboard_towns <- tribble(
  ~town,                      ~geo_id,      ~district_code,
  "Ewing township",           "3402122185", "1430",   # Ewing Township School District
  "Lawrence township",        "3402139510", "2580",   # Lawrence Township Public School District
  "Hamilton township",        "3402129310", "1950",   # Hamilton Township Public School District
  "Hopewell township",        "3402133180", "2280",   # Hopewell Valley Regional
  "Trenton city",             "3402174000", "5210",   # Trenton Public School District
  "Princeton",                "3402160900", "4255",   # Princeton Public School District
  "Hightstown borough",       "3402131620", "1245",   # East Windsor Regional
  "Robbinsville township",    "3402163850", "5510",   # Robbinsville Public School District
  "West Windsor township",    "3402180240", "5715",   # West Windsor-Plainsboro Regional
  "East Windsor township",    "3402119780", "1245",   # East Windsor Regional
  "Bordentown township",      "3400506700", "0475",   # Bordentown Regional
  "Florence township",        "3400523850", "1520",   # Florence Township School District
  "Burlington township",      "3400508950", "0620",   # Burlington Township School District
  "Chesterfield township",    "3400512670", "3690",   # Northern Burlington County Regional, grades 7 to 12
  "Mansfield township",       "3400543290", "3690",   # Northern Burlington County Regional, grades 7 to 12
  "Plainsboro township",      "3402359280", "5715",   # West Windsor-Plainsboro Regional
  "South Brunswick township", "3402368790", "4860",   # South Brunswick School District
  "Montgomery township",      "3403547580", "3320",   # Montgomery Township School District
  "Hillsborough township",    "3403531890", "2170"    # Hillsborough Township Public School District
)

# One row is one town on the dashboard. Expect 19 rows and 3 columns, and 0 rows from the key
# check. (A district code can appear twice: two towns, one regional district.)
dim(dashboard_towns)

dashboard_towns |>
  count(geo_id) |>
  filter(n > 1)


# Predict, Then Check (Step 5) -------------------------------------------------------------------

# Before the merge, what I expect:
# 1) Rows: No missing.
# 2) Columns: 3 (dashboard_towns) + 4 (5 - key) + 4 (5 - key) = 11
# 3) Drops: none. 

anti_join(dashboard_towns, rent, by = "geo_id")               # expect 0 rows

anti_join(dashboard_towns, districts, by = "district_code")   # expect 0 rows



# The Merge (Step 6) -----------------------------------------------------------------------------

# Say: "Start with dashboard_towns, add the columns of rent, matching rows by geo_id; then add the
# columns of districts, matching rows by district_code; save it as towns_merged."
towns_merged <- dashboard_towns |>
  left_join(rent, by = "geo_id") |>
  left_join(districts, by = "district_code")

# Three checks after the merge: expect 19 rows and 11 columns, and no NA in median_rent or math_ready.
# Expect rent and math/ela to be quantitative
dim(towns_merged)
names(towns_merged)
summary(towns_merged)


# Save (Step 6) ----------------------------------------------------------------------------------

write_csv(towns_merged, "data/towns_merged.csv")



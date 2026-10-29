# sta220-dashboard_where2live

**The class example for 3.2b.** This folder is what a final-project repository looks like at the
end of 3.2b: two sources in `data/`, a finished `01_import.R`, and the two scripts 3.2b adds,
`02_merge.R` and `03_math_vs_rent.R`. In your own repository these files sit at the top level,
and your figure script gets its own name. Follow the 3.2b handout; each section of the two new
scripts is marked with the handout step it goes with (Step 2 to Step 9).

**Getting the files.** In GitHub Desktop, click **Fetch origin**, then **Pull origin**; this
folder appears next to `3.2a_activity`. Then double-click `sta220-activity_3.2b.Rproj`.

## What is this?

A dashboard for a newly hired TCNJ assistant professor deciding where in New Jersey to live,
comparing 19 towns within about 30 minutes of TCNJ. This version answers one question a new hire
with children would ask first: which towns have high schools that beat the state AND rents below
the state's? It puts each town's high school district's 2024-25 NJGPA math result (NJ Department
of Education) next to the town's median rent (U.S. Census Bureau).

## Where did the data come from?

**Source 1. American Community Survey (ACS) 2020-2024 5-year estimates, U.S. Census Bureau,
table B25064, Median Gross Rent (Dollars).** For New Jersey and every New Jersey county
subdivision (in New Jersey, every county subdivision is a municipality). Downloaded October 28,
2026 from https://data.census.gov/table/ACSDT5Y2024.B25064?g=040XX00US34_040XX00US34$0600000
(that link already has both geographies selected: State > New Jersey, and County Subdivision >
New Jersey > All County Subdivisions within New Jersey). On the table, click **Download Table
Data**, choose **CSV**, and click **Download**. The zip
(`ACSDT5Y2024.B25064_2026-10-28T184708.zip`) holds three files, all in `data/` exactly as they
came out of it:

- `ACSDT5Y2024.B25064-Data.csv`: one row per place (New Jersey, 564 towns, and 5 "County
  subdivisions not defined" rows where no one lives). `GEO_ID` is the Census code, `B25064_001E`
  the estimate, and `B25064_001M` its margin of error. The second row repeats the column labels.
- `ACSDT5Y2024.B25064-Column-Metadata.csv`: what each column code means.
- `ACSDT5Y2024.B25064-Table-Notes.txt`: the Census's notes, including its symbols: `-` (no
  estimate; 16 towns), `3,500+` ($3,500 or more; 17 towns), and `**` and `***` (no margin of
  error).

**Source 2. School Performance Reports 2024-2025, NJ Department of Education, the "NJGPA"" table.**
The NJGPA is the graduation proficiency test New Jersey's 11th graders take in the spring. The
table gives each district's percent of valid scores that met the "graduation ready" standard in
English, language arts, and in math. I kept only 2024-25, the latest year. The Department's
Downloadable Data page is https://www.nj.gov/education/spr/download/, and the district and state
file for 2024-2025 is
https://www.nj.gov/education/sprreports/download/DataFiles/2024-2025/Database_DistrictStateDetail.xlsx
(119 MB, posted May 20, 2026; downloaded October 27, 2026). 

That file is too big for GitHub, so it
is listed in `.gitignore` and stays on my computer. `data/njdoe_njgpa_all_students.csv` is manually curated.

Only districts with an 11th grade have a row: 320 districts, plus a State row. About 300 New Jersey
districts are elementary only (K-6 or K-8), so they have no NJGPA result. 

The Department also posts a school-level file (`Database_SchoolDetail.xlsx`, 346 MB). I used the
district file because it already has one row per district and a State row, so it needs fewer
steps (some districts have multiple high schools! I assume the district data is either aggregated (i.e,. weighted average) 
but it may be a median or some other transformation)

If I wanted to get a finer-grained cone (i.e., census tracts), I would need school detail. 

## Curating data for import into R

`njdoe_njgpa_all_students.csv` was made from `Database_DistrictStateDetail.xlsx` (Source 2) in two ways. 

First, I imported the dataset into Claude AI and asked it to limit to the tab NJGPA, select all students,  
limit to 2024-2025 year, and remove any extra rows or columns that would prevent me from using this in R. 

Second, I followed these steps in Excel to get the manually-created copy:

1. Copy: I made a copy of the downloaded file and worked on the copy, so the download stays as it
   came.
2. Sheet: I only copied the sheet named `NJGPA` (the workbook has 81 sheets, one per table of the
   reports). To find it, right-click the arrows at the bottom left of the sheet tabs and pick
   `NJGPA` from the list.
3. Dropped rows: I deleted rows 1 to 3, which are notes about the table, so the column names are
   in row 1.
4. Dropped rows: I kept `SchoolYear` 2024-25 and `StudentGroup` "All Students"
   (321 of 19,260 rows: 320 districts and the State row, which is last). 
5. I copied the visible rows, with the header, into a new workbook, and saved it in `data/` as CSV (Comma
   delimited). There were no missing values.


Both methods returned data with the same dimensions and summary statistics. 

## How do I run it?

Open `sta220-activity_3.2b.Rproj`, then run the scripts in order: `scripts/01_import.R`,
`scripts/02_merge.R`, `scripts/03_math_vs_rent.R`. Each one reads files from `data/` and writes a
file, so each can be run on its own once the scripts before it have been run once.

Made with R version 4.3.3 and tidyverse version 2.0.0 (ggplot2 3.4.4). No other packages.

## What does each script do?

- `01_import.R` reads the ACS file and writes `data/rent_clean.csv` (one row per town) and
  `data/rent_clean_nj.csv` (New Jersey). It reads the NJGPA file and writes `data/njgpa_clean.csv`
  (one row per school district in 2024-25) and `data/njgpa_clean_nj.csv` (the State row). New
  Jersey is a benchmark, not a town or a district, so it gets its own files.
- `02_merge.R` starts from a lookup table of the 19 towns, each with its Census code and its high
  school district's code, adds both clean files, and writes `data/towns_merged.csv` (one row per
  town on the dashboard).
- `03_math_vs_rent.R` draws Figure 1 for the 19 towns: median rent on the x-axis, math readiness on
  the y-axis, the least-squares line, and New Jersey (from the two `_nj` files) as the benchmark on
  both axes. It saves `output/figures/math_vs_rent.png`.

## What is in each folder?

```
data/
  ACSDT5Y2024.B25064-Data.csv              # Source 1, exactly as downloaded (with its two
  ACSDT5Y2024.B25064-Column-Metadata.csv   #   companion files from the same zip)
  ACSDT5Y2024.B25064-Table-Notes.txt
  njdoe_njgpa_all_students.csv             # Source 2, cut by hand from the Department's Excel file
  rent_clean.csv, rent_clean_nj.csv        # made by 01_import.R
  njgpa_clean.csv, njgpa_clean_nj.csv      # made by 01_import.R
  towns_merged.csv                         # made by 02_merge.R
scripts/                                   # run in order by number
output/
  figures/math_vs_rent.png                 # made by 03_math_vs_rent.R
```

Never edit the downloaded files; the scripts make everything else, so rerun them instead of
editing their output.

## Manually curating data for import into R

`njdoe_njgpa_all_students.csv` was made from `Database_DistrictStateDetail.xlsx` (Source 2) with
these steps in Excel:

1. Sheet: I used only the sheet named `NJGPA` (the workbook has 81 sheets, one per table of the
   reports).
2. Dropped rows: I deleted rows 1 to 3, which are notes about the table, so the column names are
   in row 1.
3. Dropped rows: with Data > Filter on `StudentGroup`, I kept only "All Students" (963 of 19,260
   rows; the other 19 student groups are in the Excel file).
4. Copied the visible rows, with the header, into a new workbook and saved it as CSV UTF-8 (Comma
   delimited).
5. Nothing else was changed: all 14 columns are kept, the codes keep their leading zeros (`0110`),
   and the percents are the Department's text (`42.0%`). Check: the first data row starts
   `01,Atlantic,0110,Atlantic City School District,2022-23,All Students`.

## How the sources were merged

From `02_merge.R`:

- **Rows before:** `rent_clean` 564 (one row is a town); `njgpa_clean` 320 (one row is a school
  district in 2024-25).
- **The key:** none in common, and a town's name is not a key (New Jersey has two Hamilton,
  Hopewell, Lawrence, and Mansfield townships). A 19-row lookup table, written in the script, gives
  each town on the dashboard its Census `geo_id` and its high school district's code. Each town's
  district comes from the district's website; regional districts list the towns they serve.
- **Rows after:** 19 (the lookup table is the left table); all 19 matched both sources.
- **Not matched:** none of the 19. The other 545 towns in `rent_clean`, and 304 of the districts,
  are not on this dashboard.
- **Missing inside:** none. Towns that share a regional district share its result: East Windsor
  and Hightstown, West Windsor and Plainsboro, Chesterfield and Mansfield (grades 7 to 12).

## Who made it, and when was it last updated?

Zachary D. Kline, The College of New Jersey, with help from Claude (Anthropic). Last updated
October 28, 2026.

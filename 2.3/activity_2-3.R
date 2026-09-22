# STA 220 -- Activity 2.3: Algebra 1 to Geometry
# Name:

# 1. Set your working directory: Session > Set Working Directory > Choose Directory > sta220
#    Then copy the setwd(" line from the console and paste it on the next line.


# 2. Load the tidyverse.
library(tidyverse)

# 3. Import the four files. The .csv files must be inside your sta220 folder.
alg1_2025 <- read_csv("alg1_2025.csv")
geo_sec01 <- read_csv("geo_2026_sec01.csv")
geo_sec02 <- read_csv("geo_2026_sec02.csv")
sections  <- read_csv("sections.csv")

# 4. The three checks
# alg1_2025
dim(alg1_2025)
names(alg1_2025)
summary(alg1_2025)

# geo_sec01


# geo_sec02

# sections


# Part 2 -- Build this year's Geometry table, then check ------------------------
# 2a. Stack the two Geometry sections


# 2b. Is the key really a key? (three tables)


# 2c. Look at the offender, fix, re-check


# 2d. Who will not match? (anti_join both ways)



# Part 3 -- Join and summarize -------------------------------------------------
# 3a. Attach the teacher to each Algebra 1 student on key Section


# 3b. Correctly attach the teacher to each Algebra 1 student


# 3c. Attach this year's Geometry grade


# 3d. The principal's table



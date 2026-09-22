Codebook for math department curriculum review, fall 2026


The principal wants to know whether students' Algebra 1 grades from last
year carry into Geometry this year, and whether that depends on who taught
them Algebra 1. 

Output requested is one table showing, for each Algebra 1 teacher, how many students
they had last year, those students' average Algebra 1 final grade, and the
same students' average first-quarter Geometry grade this year.

The school year 2024-25 is "2025" everywhere below; 2025-26 is "2026".

------------------------------------------------------------------------
alg1_2025.csv       (I created this correctly)
------------------------------------------------------------------------
Every student who finished Algebra 1 last year, all four sections. One
row = one student. Students who withdrew before the end of the year are
not in this file!

    student_id   district student number
    section      section code, ALG1-01 through ALG1-04
    alg1_grade   final grade, percent

------------------------------------------------------------------------
geo_2026_sec01.csv and geo_2026_sec02.csv   (email from Mr. Patel and Ms. Duarte)
------------------------------------------------------------------------
The two regular Geometry sections this year, with first-quarter grades.
Each teacher exported their own roster from the learning management platform, Canvas. 
Same columns in both files, rows in whatever order they had the students sorted.

    student_id   district student number (same numbering as alg1_2025)
    section      GEO-01 or GEO-02
    geo_q1       first-quarter grade, percent

MISSING! Mrs. Lindqvist, who is teaching the honors section, GEO-H, has not sent her
roster yet. She has around 10 students. 

Geometry also has students who did not take Algebra 1 here last year:
a few took it in 8th grade at the middle school, and some are new students.

Quirk for Canvas: Canvas keeps an enrollment record every time a
student is added to a section. If a student's schedule was dropped and
re-added in September -- this happened at least once -- the roster export
shows that student twice. 

The instructor manually enters information from the old record to the new record,
but the new record remains.

------------------------------------------------------------------------
sections.csv        (I created this correctly)
------------------------------------------------------------------------
Which teacher taught which section. Section codes get reused every year!

    section      section code
    year         2025 (last year) or 2026 (this year)
    teacher      last name

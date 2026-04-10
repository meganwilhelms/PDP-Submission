Project Title & Description: 
PDP Submission
This project contains the SQL script and R script for completing the PDP data submission process. 

Usage:
The SQL files are designed to pull data from the SIS database tables and used in Microsoft SSMS (T-SQL). 
The .R files are to be used in R studio. 

The process for creating the PDP cohort file includes 
1) Runthe SQL_for_Cohort_file code in SSMS,
2) Import the result file into R studio,
3) Run the result file in R studio,
4) Finiale the file with any PII that needs added and header/trailer rows.

The process for creating the PDP course file includes
1) Run the SQL_for_Course_File in SSMS,
2) Import the result file into R studio plus a master cohort file. The master cohort file should contain any student IDs who have ever been submitted to PDP, their cohort year, and their cohort term.
3) Run the PDP_Course_updated.R code in R studio, 
4) Finalize the exported file with any PII and the header/trailer rows.

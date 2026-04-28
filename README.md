Project Title & Description: 
PDP Submission
This project contains the SQL script and R script for completing the PDP data submission process. 

Usage:
The SQL files are designed to pull data from the SIS database tables and used in Microsoft SSMS (T-SQL). 
The .R files are to be used in R studio. 

The process for creating the PDP cohort file includes 
1) Run the SQL_for_Cohort_file code in SSMS,
2) Import the result file into R studio (I do this with the PII columns include ssn, name, and address),
3) Run the result file in R studio using the script from R_for_Cohort_File.R,
4) Finalize the file with any PII that needs added and header/trailer rows.
5) Add the new students to a master cohort list. The master cohort list is data file containing all students who have been submitted to the PDP. The column headers are ID, Cohort (YYYY-YY), Cohort Term. This file is added onto each time a new PDP submission occurs and is used in the course file R script to verify only students who have been submitted to the PDP have course data included in the course file submission.

The process for creating the PDP course file includes
1) Run the SQL_for_Course_File in SSMS,
2) Import the result file and master cohort lsit into R studio.
3) Run the result file in R studio using the script from R_for_Course_File.R,
4) Finalize the exported file with any PII and the header/trailer rows.

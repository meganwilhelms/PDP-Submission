#11/20/2024
#Updated 4/6/2026
#Script specific to PDP Cohort file
#By: Megan Wilhelms


####Packages required for this script#############################################################################################################################
#install packages for the first time using the install.packages function
install.packages('dplyr')
install.packages('stringr')
#loading the packages
library(dplyr) 
library(stringr)

####STEP 1) File brought into R environment and final file created#################################################################################################
#File Needed:
# 1. pdp cohort file called SLRYYYYTT

cohortfile <- SLR202530 %>%
  distinct(id_num, .keep_all = TRUE) %>%
  filter(major_1!="DC") %>%
  rename("Student ID" = id_num,
         "City" = city,
         "State" = state, 
         "Zip/Postal Code" = zip, 
         "Date of Birth" = formatted_dob,
         "First Gen" = firstgen, 
         "Math Placement" = "math_placement2", 
         "English Placement" = "english_placement2", 
         "Enrollment Type" = enrolltype,
         "Ethnicity" = ethnicity, 
         "Race" = race, 
         "Gateway Math Status" = gateway_math_status, 
         "Gateway English Status" = gateway_english_status) %>%
  replace(is.na(.), "") %>% 
  mutate(CH1 = ("D1"),
         Cohort = ("2025-26"),  #!!!!UPDATE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         'Cohort Term' = ("Fall"),
         'Cohort Term Begin Date' = (20250826), ###CHANGE BASED ON TERM!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         'Cohort Term End Date' = (20251212), ###CHANGE BASED ON TERM!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         SSN = (""), 
         ITIN = (""), 
         'First Name'= (""), 
         'Middle Name' = (""), 
         'Last Name' = (""), 
         'Street Line 1' = (""),
         'Street Line 2' = (""), 
         City = (""),
         'Zip/Postal Code' = (""),
         Country = (""),
         'Institution ID Type' = ("OPEID"),
         'Institution ID' = (c("02242900")),
         'HS Completion Status' = (""), 'HS Completion Year' = (""), 'HS Unweighted GPA' = (""), 'HS Weighted GPA' = (""), 
         'Dual and Summer Enrollment' = (""), 'Number of College Credits Attempted to Transfer' = (""), 'Number of College Transfer Credits Accepted' = ("")) %>% #no Version 2.0 vars added
  select(CH1, Cohort, 'Cohort Term', 'Cohort Term Begin Date', 'Cohort Term End Date', SSN, 
         ITIN, 'Student ID', 'First Name', 'Middle Name','Last Name', 'Street Line 1', 'Street Line 2', City, State, 'Zip/Postal Code', Country, 'Date of Birth', 'Ethnicity','Race', 'Institution ID Type', 
         'Institution ID', 'HS Completion Status', 'HS Completion Year', 'HS Unweighted GPA', 'HS Weighted GPA', 'First Gen', 
         'Dual and Summer Enrollment', 'Enrollment Type', 'Number of College Credits Attempted to Transfer', 'Number of College Transfer Credits Accepted', 'Math Placement', 'English Placement',
         'Gateway Math Status', 'Gateway English Status')

####STEP 2) EXPORT FILE OUT OF R ENVIRONMENT INTO FILE EXPLORER
writexl::write_xlsx(cohortfile,  "U:/R/PDP/PDPCohortfile202530_test.xlsx", format_headers = FALSE ) ##change values to how you want the file named 

#Instructions after: 
#compare student IDs to master cohort list and each term to check for duplicates, remove the newest duplicates
#after completing cohort file - 
#Use Vlookup to fill in PII columns
#Add new students to the master cohort list

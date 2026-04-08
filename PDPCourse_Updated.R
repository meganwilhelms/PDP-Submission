#11/20/2024
#Updated 4/7/2026
#Script specific to PDP Course file
#By: Megan Wilhelms

#Two Files Needed: Master Cohort List, Student Listing Report

####Packages required or this script################################################################
#install package tidyr for the first time using the package
install.packages('tidyr')

#loading the packages
library(stringr)
library(dplyr) 
library(tidyr)



###STEP 1) Initial processing of the student + course file and creating of the CompleteDev courses
steponefile <- courses %>%
  mutate(course = substr(crs_cde, 1, 3),  
         coursenum = substr(crs_cde, 6, 8),
         section = substr(crs_cde, 11, 13), 
         crs_num = substr(crs_cde, 1, 8)) %>%
  mutate(                              #This mutate is just a middle step to ultimately create the CompleteDevMath and English variables
    devcourse = case_when(
      course=="ASC"&coursenum=="087"&(grade_cde=="A"|grade_cde=="B"|grade_cde=="C") ~ "engpass",
      course=="ASC"&coursenum=="087"&(grade_cde=="D"|grade_cde=="F"|grade_cde=="W") ~ "engfail",
      course=="ASC"&coursenum=="091"&(grade_cde=="A"|grade_cde=="B"|grade_cde=="C") ~ "mathpass", 
      course=="ASC"&coursenum=="091"&(grade_cde=="D"|grade_cde=="F"|grade_cde=="W") ~ "mathfail", 
      course=="ASC"&coursenum=="090"&(grade_cde=="D"|grade_cde=="F"|grade_cde=="W") ~ "mathfail", 
      course=="ASC"&coursenum=="090"&(grade_cde=="A"|grade_cde=="B"|grade_cde=="C") ~"mathpartpass")) %>% 
  group_by(id_num) %>%
  mutate(                            #This mutate and group/ungroup is another middle step for the CompleteDevMath and English variables
    engpass = any(str_detect(devcourse, "engpass")), 
    mathpass = any(str_detect(devcourse, "mathpass")), 
    engfail = any(str_detect(devcourse, "engfail")), 
    mathfail = any(str_detect(devcourse, "mathfail"))) %>%
  ungroup() %>%
  mutate(
    CompleteDevMath = case_when(
      mathpass==TRUE ~ "C", 
      mathfail==TRUE ~ "D",
      .default = "NA"), 
    CompleteDevEnglish = case_when(
      engpass==TRUE ~ "C", 
      engfail==TRUE ~ "D", 
      .default = "NA"),
    crs_name = case_when(
      crs_name=="Ochéthi Šakówin(Seven Council Fire) History and Culture"~"Ochéthi Šakówin History and Culture",
      crs_name=="Social Studies and Geography in the Elementary Classroom"~"Social Studies and Geography in the Elem Classroom",
      .default = crs_name),
    grade_cde = case_when(
      grade_cde=="A"|grade_cde=="B"|grade_cde=="C"|grade_cde=="P"~"P", 
      grade_cde=="D"|grade_cde=="F"~"F", 
      grade_cde=="W"~"W")) %>%
  select(id_num, trm_cde, formatted_dob, 'pell recipient', 'degree type sought', course, coursenum, section, cip, course_type, crs_name, mathorenglishgateway, credit_hrs, cred_earned, 
         grade_cde, "course begin date", "course end date", CompleteDevMath, CompleteDevEnglish, career_gpa, trm_gpa)


###STEP 2) PROCESSING STUDENT LISTING REPORT and joining student information with courses information
#Need Master Cohort List for this section - this is so only student course information on students who exist in the cohort list are added nto the file
steptwofile <- steponefile %>%
  mutate(  
    CH1 = "D1",
    "Academic Year" = ("2025-26"), ##########UPDATE##########################################################
    Term = case_when(
      trm_cde=="30"~"Fall", trm_cde=="40"~"Spring", trm_cde=="60"~"Summer"),
    'Institution ID Type' = ("OPEID"),
    'Institution ID' = (c("02242900")),
    career_gpa = formatC(career_gpa, digits=2, format = "f"),
    trm_gpa = formatC(trm_gpa, digits=2, format = "f"),
    credit_hrs = formatC(credit_hrs, digits=2, format = "f"),
    cred_earned = formatC(cred_earned, digits=2, format = "f"),
    CIP = formatC(cip, digits=6, format = "f"),
    SSN = (""), 
    ITIN = (""),
    'First Name'= (""), 
    'Middle Name' = (""), 
    'Last Name' = (""), 
    'Suffix' = (""), 
    'Current Street 1' = (""),
    'Current Street 2' = (""), 
    'Current City' = (""),
    'Current State' = (""),
    'Current Zip/Postal Code' = (""),
    'Current Country' = (""),
    'Date of Birth' = (""),
    'Student Phone Number' = (""), 
    'Student Email' = (""),
    'TransferIntent' = (""),
    'Course Description' = (""),
    'Co-requisite Course' = (""),
    'Delivery Method' = case_when(
      section=="OL"~"O", .default = "F"), 
    'Core Course' = (""),
    'Core Course Type' = (""),
    'Core Competency Completed' = (""),
    'Total Combined Earned and Transferred Credits' = (""), 
    'Purpose of Course Exchange' = ("2"),
    'Certification Endorsed Curriculum/Program' = (""), 
    'Certificate Endorsing Industry' = (""), 
    'Grade Effective Date' = (""), 
    'DGI Institution ID Type' = (""), 
    'DGI Institution ID' = (""), 
    'DGI Student ID' = ("")) %>%
  rename("Semester/Session GPA" = trm_gpa, 
         "Overall GPA" = career_gpa, 
         "Student ID" = id_num, 
         "Course Prefix" = course, 
         "Course Number" = coursenum, 
         "Section ID"= section,
         "Course Name" = crs_name,
         "Course CIP" = CIP, 
         "Grade" = grade_cde, 
         "Number of Credits Attempted" = credit_hrs, 
         "Number of Credits Earned" = cred_earned,
         "Course Type" = course_type,
         "Pell Recipient" = 'pell recipient',
         "Degree Type Sought" = 'degree type sought',
         "Course Begin Date" = "course begin date",
         "Course End Date" = "course end date",
          MathOrEnglishGateway = "mathorenglishgateway") %>%
inner_join(Master_Cohort_List[c("ID", "Cohort", "Cohort Term")], by= c("Student ID" = "ID")) %>% 
  #innerjoin removed any student ID that didn't match in both files; cohort file must be updated to include the students identified in the cohort file 
  select(CH1, #Cohort, 'Cohort Term',
         'Academic Year', Term, 'Institution ID Type', 'Institution ID', SSN, ITIN, 'Student ID', 'First Name', 'Middle Name', 'Last Name', 'Suffix', 
         'Current Street 1', 'Current Street 2','Current City', 'Current State', 'Current Zip/Postal Code', 'Current Country', 'Date of Birth','Student Phone Number', 
         'Pell Recipient', 'Student Email', CompleteDevMath, CompleteDevEnglish, 'TransferIntent', 'Degree Type Sought', 
         'Semester/Session GPA', 'Overall GPA', 'Course Prefix', 'Course Number', 'Section ID', 'Course Name', 'Course Description', 'Course CIP',
         'Course Type', MathOrEnglishGateway, 'Co-requisite Course', 'Course Begin Date', 'Course End Date',
         Grade,'Number of Credits Attempted', 'Number of Credits Earned', 'Delivery Method', 'Core Course', 'Core Course Type', 'Core Competency Completed', 'Total Combined Earned and Transferred Credits', 'Purpose of Course Exchange',
         'Certification Endorsed Curriculum/Program', 'Certificate Endorsing Industry', 'Grade Effective Date', 'DGI Institution ID Type', 'DGI Institution ID', 'DGI Student ID') 


##STEP 3. Exporting the file.
writexl::write_xlsx(steptwofile,  "U:/R/PDP/PDPCourses302025.xlsx", format_headers = FALSE )

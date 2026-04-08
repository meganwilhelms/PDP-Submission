WITH DistinctPell AS ( 
  SELECT pfsa.ID_NUM, pffcm.FUND_DESC, pfpd.POE_DESC, pfpd.POE_START_DTE
  FROM TmsEPrd.dbo.PF_STDNT_AWARD pfsa
		LEFT JOIN TmsEPrd.dbo.PF_FUND_CDE_MSTR pffcm ON pfsa.FUND_CDE = pffcm.FUND_CDE
		LEFT JOIN TmsEPrd.dbo.PF_POE_DEF pfpd ON pfsa.POE_ID = pfpd.POE_ID
  WHERE pffcm.fund_cde = '773' AND pfpd.POE_START_DTE =:Term_Start_Date
  )
SELECT DISTINCT sch.id_num, stsd.YR_CDE, stsd.TRM_CDE, 
		nm.FIRST_NAME, nm.MIDDLE_NAME, nm.LAST_NAME,
		am.ADDR_LINE_1, am.ADDR_LINE_2, am.CITY, am.STATE, am.ZIP,
		FORMAT(CAST(bm.birth_dte as date), 'yyyyMMdd') AS formatted_dob,
		CASE
			WHEN dp.FUND_DESC='FEDERAL PELL GRANT' THEN 'Y'
			ELSE 'N'
		END AS 'Pell Recipient',
		CASE
			WHEN stsd.DEGREE_CDE in ('AS', 'AAS') THEN 'A'
			WHEN stsd.DEGREE_CDE = 'BS' THEN 'B'
			WHEN stsd.DEGREE_CDE in ('CERT','DIPLM') THEN 'C1' --C1=less than 1yr cert, less than associates degree
			WHEN stsd.DEGREE_CDE = 'NON' THEN 'NC'
		END AS 'Degree Type Sought',
		stsd.TRM_GPA, stsd.CAREER_GPA,
		CASE WHEN sch.CRS_CDE = 'GPE  104  OL' THEN 'GPE  104  A'
		ELSE CRS_CDE END AS crs_cde, 
		sch.CRS_TITLE, sch.CRS_TITLE_2,
		LEFT(CONCAT(sch.CRS_TITLE, ' ', sch.CRS_TITLE_2), 500) AS crs_name,
		FORMAT(CAST(sch.BEGIN_DTE as date), 'yyyyMMdd') AS 'Course Begin Date', 
		FORMAT(CAST(sch.END_DTE as date), 'yyyyMMdd') AS 'Course End Date',
		CASE
			WHEN sch.CRS_CDE like 'ASC%' THEN 'CD'
			ELSE 'CU'
		END AS course_type, 
		CAST(CAST(sch.IPEDS_CIP_CDE AS FLOAT)/10000 AS DECIMAL (6,4)) AS CIP,
		sch.GRADE_CDE, sch.CREDIT_HRS, sch.HRS_EARNED, 
		CASE
			WHEN sch.GRADE_CDE in ('A','B', 'C', 'P') THEN sch.CREDIT_HRS
			WHEN sch.GRADE_CDE in ('D', 'F', 'W') THEN 0
		END AS cred_earned,
		stsd.MAJOR_1, stsd.MAJOR_2, 
		CASE  
			WHEN stsd.MAJOR_1 in ('BAD', 'BADOL', 'IFA') AND (sch.CRS_CDE like 'MTH  102%' OR sch.crs_cde like 'MTH  103%' OR sch.CRS_CDE like 'MTH  104%') THEN 'M'
			WHEN stsd.MAJOR_1 in ('CIT', 'CIS') AND (sch.CRS_CDE like 'MTH  102%' OR sch.CRS_CDE like 'MTH  210%') THEN 'M'
			WHEN stsd.MAJOR_1 in ('EDU', 'GENA', 'GENO', 'GENOL', 'HPR', 'PAR', 'CJU', 'CJAAO', 'ADS', 'AGR') AND SCH.CRS_CDE LIKE 'MTH  102%' THEN 'M'
			WHEN stsd.MAJOR_1 in ('BSBAD', 'BSBAO', 'BSEDU', 'HSS') AND (SCH.CRS_CDE LIKE 'MTH  103%' OR SCH.CRS_CDE LIKE 'MTH  104%') THEN 'M'
			WHEN STSD.MAJOR_1 IN ('BSCJU', 'BSCJO', 'SWK', 'SWKAS') AND (sch.CRS_CDE like 'MTH  103%' OR sch.crs_cde like 'MTH  104%' OR sch.CRS_CDE like 'MTH  210%') THEN 'M'
			WHEN stsd.MAJOR_1 IN ('BSESR', 'ESR') AND SCH.CRS_CDE LIKE 'MTH  107%' THEN 'M'
			WHEN STSD.MAJOR_1 IN ('ENVR', 'ENR') AND SCH.CRS_CDE LIKE 'MTH  165%' THEN 'M'
			WHEN stsd.MAJOR_1 = 'INDL' AND (SCH.CRS_CDE LIKE 'MTH  102%' OR SCH.CRS_CDE LIKE 'MTH  103%' OR SCH.CRS_CDE LIKE 'MTH  104%' OR SCH.CRS_CDE LIKE 'MTH  210%') THEN 'M'
			WHEN stsd.MAJOR_1 IN ('FWAS', 'FWBS') AND SCH.CRS_CDE LIKE 'MTH  107%' THEN 'M'
			WHEN stsd.MAJOR_1 IN ('AUTDL', 'HEOC', 'WLD') AND SCH.CRS_CDE LIKE 'MTH  106%' THEN 'M'
			WHEN stsd.MAJOR_1 = 'AUTDL' AND SCH.CRS_CDE LIKE 'ENG  105%' THEN 'E'
			WHEN SCH.CRS_CDE LIKE 'ENG  110%' THEN 'E'
		END AS MathOrEnglishGateway
	FROM TmsEPrd.dbo.STUD_TERM_SUM_DIV stsd
			LEFT JOIN TmsEPrd.dbo.STUDENT_CRS_HIST sch on stsd.ID_NUM=sch.ID_NUM AND stsd.YR_CDE=sch.YR_CDE AND stsd.TRM_CDE=sch.TRM_CDE
			LEFT JOIN TmsEPrd.dbo.STUDENT_MASTER sm ON sch.ID_NUM=sm.ID_NUM
			LEFT JOIN TmsEPrd.dbo.name_master nm ON stsd.ID_NUM = nm.ID_NUM   
			LEFT JOIN TmsEPrd.dbo.biograph_master bm ON stsd.ID_NUM = bm.ID_NUM
			LEFT JOIN TmsEPrd.dbo.address_master am ON stsd.ID_NUM = am.ID_NUM  
			LEFT JOIN DistinctPell dp ON stsd.ID_NUM=dp.ID_NUM,
		TmsEPrd.dbo.REG_CONFIG rg		
WHERE stsd.hrs_enrolled>0 AND am.ADDR_CDE='*LHP' AND
	  stsd.YR_CDE =:YEAR AND stsd.TRM_CDE =:TERM AND 
		(rg.reg_config_cde = '1' AND  
		sch.transaction_sts in ('C', 'H', 'P', 'R', 'W') AND 
				(((sm.hold_1_cde is NULL OR sm.hold_1_cde = '') AND (sm.hold_2_cde is NULL OR sm.hold_2_cde = '') AND (sm.hold_3_cde is NULL OR sm.hold_3_cde = '') AND  
				(sm.hold_4_cde is NULL OR sm.hold_4_cde = '') AND (sm.hold_5_cde is NULL OR sm.hold_5_cde = '') AND (sm.hold_6_cde is NULL OR sm.hold_6_cde = '')) OR  
rg.clas_lst_incl_hold = 'Y'))





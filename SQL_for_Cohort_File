 --THIS SECTION CREATES A SCORE VALUE FOR EACH TEST TYPE.
WITH SCORES AS( 
SELECT hts.IDNumber AS ID_NUM, hts.TestElementCode, 
	CASE
		WHEN hts.TestElementCode='ACTEN'AND hts.TestScore<=17 THEN 1	--ASC 087
		WHEN hts.TestElementCode='ACTEN'AND hts.TestScore>=18 THEN 2	--ENG 104/110
		WHEN hts.TestElementCode='ACTEN'AND hts.TestScore is null THEN 0 --test not taken
		END AS score_act_english1,
	CASE
		WHEN hts.TestElementCode='ACTMT' AND hts.TestScore<=12 THEN 1 --ASC090
		WHEN hts.TestElementCode='ACTMT' AND hts.TestScore>=13 AND hts.TestScore<=15 THEN 2 --ASC091
		WHEN hts.TestElementCode='ACTMT' AND hts.TestScore>=16 AND hts.TestScore<=18 THEN 3 --MTH101
		WHEN hts.TestElementCode='ACTMT' AND hts.TestScore>=19 AND hts.TestScore<=20 THEN 4 --MTH102
		WHEN hts.TestElementCode='ACTMT' AND hts.TestScore>=21 THEN 5 --MTH103/104/210
		WHEN hts.TestElementCode='ACTMT' AND hts.TestScore is null THEN 0 --test not taken
		END AS score_act_math1,
	CASE
		WHEN hts.TestElementCode='ARITX' and hts.TestScore <=224 THEN 1 --ASC090
		WHEN hts.TestElementCode='ARITX' and hts.TestScore>=225 AND hts.TestScore<=236 THEN 2 --ASC091
		WHEN hts.TestElementCode='ARITX' and hts.TestScore>=237 AND hts.TestScore<=245 THEN 3 --MTH101
		WHEN hts.TestElementCode='ARITX' and hts.TestScore>=246 AND hts.TestScore<=254 THEN 4 --MTH102
		WHEN hts.TestElementCode='ARITX' and hts.TestScore>254 THEN 5 --MTH103/104/210
		WHEN hts.TestElementCode='ARITX' and hts.TestScore is null THEN 0 --TEST NOT TAKEN
		END AS score_accup_math2,
	CASE
		WHEN hts.TestElementCode='WRITX' AND hts.TestScore<=225 THEN 1	--ASC 087
		WHEN hts.TestElementCode='WRITX' AND hts.TestScore>=226 THEN 2 --ENG 104/110
		WHEN hts.TestElementCode='WRITX' AND hts.TestScore is null THEN 0 --TEST NOT TAKEN
		END AS score_accup_english2
FROM TmsEPrd.dbo.TEST_INFORMATION_V hts
WHERE hts.TestElementCode IN ('ACTEN', 'ACTMT','ARITX','WRITX') AND :YEAR-YEAR(hts.DateTaken)<=5
),

--THIS SECTIONS REMOVES NULLS AND JOINS THE SCORES WITH THE STUD_TERM_SUM_DIV TABLE (SO ONLY CURRENT TERM STUDENT SCORES ARE USED).
RemovingNulls AS (
SELECT stsd.ID_NUM, stsd.TRM_CDE, stsd.YR_CDE, 
	CASE WHEN score_act_math1 is null THEN 0 ELSE score_act_math1 END AS score_act_math1,
	CASE WHEN score_accup_math2 is null THEN 0 ELSE  score_accup_math2 END AS score_accup_math2,
	CASE WHEN score_act_english1 is null THEN 0 ELSE  score_act_english1 END AS score_act_english1,
	CASE WHEN score_accup_english2 is null THEN 0 ELSE  score_accup_english2 END AS score_accup_english2
FROM TmsEPrd.dbo.STUD_TERM_SUM_DIV stsd
	LEFT JOIN SCORES ON stsd.ID_NUM = SCORES.ID_NUM
WHERE stsd.HRS_ENROLLED>'0' AND stsd.YR_CDE=:YEAR AND stsd.TRM_CDE=:TERM),

--THIS SECTION IS WHERE THE SCORES ARE COMPARED AND THE HIGHER OF THE SCORES IS USED (act math vs. accuplacer math and the higher of the two used)
CombiningScores AS(
SELECT RemovingNulls.ID_NUM, RemovingNulls.trm_cde, RemovingNulls.YR_CDE, 
	CASE WHEN RemovingNulls.score_ACT_math1 >= RemovingNulls.score_accup_math2 THEN RemovingNulls.score_act_math1
		ELSE RemovingNulls.score_accup_math2 END AS Math_Placement,
	CASE WHEN RemovingNulls.score_act_english1 >= RemovingNulls.score_accup_english2 THEN RemovingNulls.score_act_english1
		ELSE RemovingNulls.score_accup_english2 END AS English_Placement
FROM RemovingNulls),
GroupScores AS (
SELECT CombiningScores.ID_NUM, CombiningScores.TRM_CDE, CombiningScores.YR_CDE, 
	MAX(COMBININGSCORES.Math_Placement) AS Math_Placement,
	MAX(COMBININGSCORES.English_Placement) AS English_Placement
FROM CombiningScores
GROUP BY ID_NUM, TRM_CDE, YR_CDE
),
--THIS SECTION ASSIGNS THE PLACEMENT VALUES AS THE APPLICABLE PDP VALUE
PlacementValues AS (
SELECT cs.ID_NUM, cs.TRM_CDE, cs.YR_CDE,
cs.Math_Placement, 
CASE 
	WHEN cs.Math_Placement=0 THEN 'UK' --No Testing Completed
	WHEN cs.Math_Placement=1 THEN 'N' --ASC  090
	WHEN cs.Math_Placement=2 THEN 'N' --ASC  091
	WHEN cs.Math_Placement=3 THEN 'C' --MTH  101
	WHEN cs.Math_Placement=4 THEN 'C' --MTH 102
	WHEN cs.Math_Placement=5 THEN 'C' --MTH  103/104/210
	END AS Math_Placement2,
cs.English_Placement,
CASE	
	WHEN cs.English_Placement=0 THEN 'UK' --NO TESTING COMPLETED
	WHEN cs.English_Placement=1 THEN 'N' --ASC  087
	WHEN cs.English_Placement=2 THEN 'C' --ENG  110/104
	END AS English_Placement2
FROM GroupScores cs
)

--FINAL QUERY THAT TIES IT ALL TOGETHER-------------------------------------------------------------------
SELECT DISTINCT 
	stsd.id_num, stsd.yr_cde, stsd.trm_cde,    
    ssn, first_name, last_name, 
    addr_line_1, addr_line_2, city, state, zip, 
	FORMAT(CAST(bm.birth_dte as date), 'yyyyMMdd') AS formatted_dob,
	stsd.major_1, 
		 CASE 
			WHEN c.CANDIDACY_TYPE='T' THEN 'T'
			WHEN c.CANDIDACY_TYPE='N' THEN 'F'
			ELSE 'WARNING'
		 END AS enrolltype,
		 CASE 
			WHEN bm.ETHNIC_GROUP = 1 THEN 'B'
			WHEN bm.ETHNIC_GROUP = 2 THEN 'IA'
			WHEN bm.ETHNIC_GROUP = 3 THEN 'HP'
			WHEN bm.ETHNIC_GROUP = 5 THEN 'W'
			WHEN bm.ETHNIC_GROUP = 6 THEN 'A'
			WHEN bm.ETHNIC_GROUP = 7 THEN 'TM'
			WHEN bm.ETHNIC_GROUP = 9 THEN 'IA'
			ELSE 'Needs filled in for sql'
		END AS race,
		CASE
			WHEN ethnic_race_v.ETHNIC_RPT_DESC = 'Not Hispanic/Latino' THEN 'N'
			WHEN ethnic_race_v.ETHNIC_RPT_DESC = 'Hispanic/Latino' THEN 'H'
			ELSE 'UK'
		END AS ethnicity,
		CASE
			WHEN bm.udef_1a_1 = 'Y' THEN 'N'
			WHEN bm.udef_1a_1 = 'N' THEN 'B'
		END AS firstgen, 
		Math_Placement2 AS math_placement2, English_Placement2 AS english_placement2, 
		CASE 
			WHEN stsd.MAJOR_1 in ('ADS', 'AGR', 'ARTG', 'AUT', 'AUTDL', 'BAD', 'BADOL', 'BSBAD', 'BSBAO', 'BSCJU', 'BSCJO', 'BSEDU', 'BSESR', 'CIS', 'CIT', 'CJAAO', 'CJU', 'EDU', 'ENR', 'ENVR', 'ESR', 'FWAS', 'FWBS', 'GENA', 'GENO', 'GENOL', 'HPR', 'HSS', 'IFA', 'INDL', 'PAR', 'SWK', 'SWKAS') THEN 'R'
			WHEN stsd.MAJOR_1 in ('CVO', 'CVOC', 'HEOC', 'NON', 'WLD') THEN 'N'
		END AS gateway_english_status,
		CASE
			WHEN stsd.MAJOR_1 in ('ADS', 'AGR', 'ARTG', 'AUT', 'AUTDL', 'BAD', 'BADOL', 'BSBAD', 'BSBAO', 'BSCJO', 'BSCJU', 'BSEDU', 'BSESR', 'CIS', 'CIT', 'CJAAO', 'CJU', 'EDU', 'ENR', 'ENVR', 'ESR', 'FWAS', 'FWBS', 'GENA', 'GENO', 'GENOL', 'HEOC', 'HPR', 'HSS', 'IFA', 'INDL', 'PAR', 'SWK', 'SWKAS', 'WLD') THEN 'R'
			WHEN stsd.MAJOR_1 IN ('CVO', 'CVOC', 'DC', 'NON') THEN 'N'
		END AS gateway_math_status
FROM TmsEPrd.dbo.stud_term_sum_div stsd  
         LEFT JOIN TmsEPrd.dbo.name_master nm ON stsd.ID_NUM = nm.ID_NUM   
         LEFT JOIN TmsEPrd.dbo.biograph_master bm ON stsd.ID_NUM = bm.ID_NUM
         LEFT JOIN TmsEPrd.dbo.address_master am ON stsd.ID_NUM = am.ID_NUM  
         LEFT JOIN TmsEPrd.dbo.student_master sm ON stsd.ID_NUM = sm.ID_NUM
		 LEFT JOIN TmsEPrd.dbo.CANDIDACY c ON stsd.ID_NUM=c.ID_NUM AND stsd.YR_CDE=c.YR_CDE AND stsd.TRM_CDE=c.TRM_CDE
		 LEFT JOIN TmsEPrd.dbo.ethnic_race_v ON stsd.ID_NUM=ethnic_race_v.id_num
		 LEFT JOIN PlacementValues pv ON stsd.ID_NUM=pv.ID_NUM
WHERE stsd.YR_CDE=:YEAR AND stsd.TRM_CDE = :TERM AND
	  stsd.hrs_enrolled > '0' AND  am.addr_cde = '*LHP' AND 
	  (c.CANDIDACY_TYPE='T' OR c.CANDIDACY_TYPE='N') AND stsd.MAJOR_1 != 'DC' --only includes new/transfer students; excludes current dual credit students

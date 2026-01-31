-------------------
-- DATA PROFILING
-------------------

USE ROLE TRAINING_ROLE;
USE WAREHOUSE BISON_WH;
USE DATABASE GRP5_ASG;
USE SCHEMA GRP5_ASG.RAW;

-- ADMISSIONS
CREATE OR REPLACE TABLE STAGING.ADMISSIONS_CLEAN AS
SELECT * FROM RAW.admissions;


-- See first 10 rows
SELECT * 
FROM STAGING.admissions_clean
LIMIT 10;

-- Check row count
SELECT COUNT(*) 
FROM STAGING.admissions_clean;

-- See the structure
DESCRIBE TABLE STAGING.admissions_clean;

-- Counts the number of null for each value
SELECT
    COUNT(*) - COUNT(row_id) as row_id_nulls,
    COUNT(*) - COUNT(subject_id) as subject_id_nulls,
    COUNT(*) - COUNT(hadm_id) as hadm_id_nulls,
    COUNT(*) - COUNT(admittime) as admittime_nulls,
    COUNT(*) - COUNT(dischtime) as dischtime_nulls,
    COUNT(*) - COUNT(deathtime) as deathtime_nulls,
    COUNT(*) - COUNT(admission_type) as admission_type_nulls,
    COUNT(*) - COUNT(admission_location) as admission_location_nulls,
    COUNT(*) - COUNT(discharge_location) as discharge_location_nulls,
    COUNT(*) - COUNT(insurance) as insurance_nulls,
    COUNT(*) - COUNT(language) as language_nulls,
    COUNT(*) - COUNT(religion) as religion_nulls,
    COUNT(*) - COUNT(marital_status) as marital_status_nulls,
    COUNT(*) - COUNT(ethnicity) as ethnicity_nulls,
    COUNT(*) - COUNT(edregtime) as edregtime_nulls,
    COUNT(*) - COUNT(edouttime) as edouttime_nulls,
    COUNT(*) - COUNT(diagnosis) as diagnosis_nulls,
    COUNT(*) - COUNT(hospital_expire_flag) as hospital_expire_flag_nulls,
    COUNT(*) - COUNT(has_chartevents_data) as has_chartevents_data_nulls
FROM STAGING.admissions_clean;

-- Shows the number of distinct values for each record
SELECT 
    COUNT(DISTINCT row_id) as row_id_distinct,
    COUNT(DISTINCT subject_id) as subject_id_distinct,
    COUNT(DISTINCT hadm_id) as hadm_id_distinct,
    COUNT(DISTINCT admittime) as admittime_distinct,
    COUNT(DISTINCT dischtime) as dischtime_distinct,
    COUNT(DISTINCT deathtime) as deathtime_distinct,
    COUNT(DISTINCT admission_type) as admission_type_distinct,
    COUNT(DISTINCT admission_location) as admission_location_distinct,
    COUNT(DISTINCT discharge_location) as discharge_location_distinct,
    COUNT(DISTINCT insurance) as insurance_distinct,
    COUNT(DISTINCT language) as language_distinct,
    COUNT(DISTINCT religion) as religion_distinct,
    COUNT(DISTINCT marital_status) as marital_status_distinct,
    COUNT(DISTINCT ethnicity) as ethnicity_distinct,
    COUNT(DISTINCT edregtime) as edregtime_distinct,
    COUNT(DISTINCT edouttime) as edouttime_distinct,
    COUNT(DISTINCT diagnosis) as diagnosis_distinct,
    COUNT(DISTINCT hospital_expire_flag) as hospital_expire_flag_distinct,
    COUNT(DISTINCT has_chartevents_data) as has_chartevents_data_distinct
FROM STAGING.admissions_clean;

-- confirm the primary key
SELECT 
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT row_id) 
        THEN 'ROW_ID is unique' 
        ELSE 'ROW_ID has duplicates' 
    END AS row_id_check
FROM STAGING.admissions_clean;

SELECT 
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT hadm_id) 
        THEN 'ROW_ID is unique' 
        ELSE 'ROW_ID has duplicates' 
    END AS row_id_check
FROM STAGING.admissions_clean;

-- PATIENTS
-- Create a new table in STAGING that you can edit
CREATE OR REPLACE TABLE STAGING.PATIENTS_CLEAN AS
SELECT * FROM RAW.patients;


-- See first 10 rows
SELECT * 
FROM STAGING.patients_clean
LIMIT 10;

-- Check row count
SELECT COUNT(*) 
FROM STAGING.patients_clean;

-- See the structure
DESCRIBE TABLE STAGING.patients_clean;

-- Counts the number of null for each value
SELECT
    COUNT(*) - COUNT(row_id) as row_id_nulls,
    COUNT(*) - COUNT(subject_id) as subject_id_nulls,
    COUNT(*) - COUNT(gender) as gender_nulls,
    COUNT(*) - COUNT(dob) as dob_nulls,
    COUNT(*) - COUNT(dod) as dod_nulls,
    COUNT(*) - COUNT(dod_hosp) as dod_hosp_nulls,
    COUNT(*) - COUNT(dod_ssn) as dod_ssn_nulls,
    COUNT(*) - COUNT(expire_flag) as expire_flag_nulls
FROM STAGING.patients_clean;

-- Shows the number of distinct values for each record
SELECT 
    COUNT(DISTINCT row_id) as row_id_distinct,
    COUNT(DISTINCT subject_id) as subject_id_distinct,
    COUNT(DISTINCT gender) as gender_distinct,
    COUNT(DISTINCT dob) as dob_distinct,
    COUNT(DISTINCT dod) as dod_distinct,
    COUNT(DISTINCT dod_hosp) as dod_hosp_distinct,
    COUNT(DISTINCT dod_ssn) as dod_ssn_distinct,
    COUNT(DISTINCT expire_flag) as expire_flag_distinct
FROM STAGING.patients_clean;

-- confirm the primary key
SELECT 
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT row_id) 
        THEN 'ROW_ID is unique' 
        ELSE 'ROW_ID has duplicates' 
    END AS row_id_check
FROM STAGING.patients_clean;

SELECT 
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT subject_id) 
        THEN 'ROW_ID is unique' 
        ELSE 'ROW_ID has duplicates' 
    END AS row_id_check
FROM STAGING.patients_clean;

-- TRANSFERS

CREATE OR REPLACE TABLE STAGING.TRANSFERS_CLEAN AS
SELECT * FROM RAW.transfers;

-- See first 10 rows
SELECT * 
FROM STAGING.transfers_clean
LIMIT 10;

-- Check row count
SELECT COUNT(*) 
FROM STAGING.transfers_clean;

-- See the structure
DESCRIBE TABLE STAGING.transfers_clean;

-- Counts the number of null for each value
SELECT
    COUNT(*) - COUNT(row_id) as row_id_nulls,
    COUNT(*) - COUNT(subject_id) as subject_id_nulls,
    COUNT(*) - COUNT(hadm_id) as hadm_id_nulls,
    COUNT(*) - COUNT(icustay_id) as icustay_id_nulls,
    COUNT(*) - COUNT(dbsource) as dbsource_nulls,
    COUNT(*) - COUNT(eventtype) as eventtype_nulls,
    COUNT(*) - COUNT(prev_careunit) as prev_careunit_nulls,
    COUNT(*) - COUNT(curr_careunit) as curr_careunit_nulls,
    COUNT(*) - COUNT(prev_wardid) as prev_wardid_nulls,
    COUNT(*) - COUNT(curr_wardid) as curr_wardid_nulls,
    COUNT(*) - COUNT(intime) as intime_nulls,
    COUNT(*) - COUNT(outtime) as outtime_nulls,
    COUNT(*) - COUNT(los) as los_nulls
FROM STAGING.transfers_clean;

-- How many transfers per patient?
SELECT 
    subject_id,
    COUNT(*) as transfer_count
FROM STAGING.transfers_clean
GROUP BY subject_id
ORDER BY transfer_count DESC;

-- ROW_ID should be unique (one per transfer event)
SELECT 
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT row_id) 
        THEN 'ROW_ID is unique' 
        ELSE 'ROW_ID has duplicates' 
    END AS primary_key_check,
    COUNT(*) as total_rows,
    COUNT(DISTINCT row_id) as unique_row_ids
FROM STAGING.transfers_clean;

-- ROW_ID should be unique (one per transfer event)
SELECT 
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT subject_id) 
        THEN 'ROW_ID is unique' 
        ELSE 'ROW_ID has duplicates' 
    END AS primary_key_check,
    COUNT(*) as total_rows,
    COUNT(DISTINCT row_id) as unique_row_ids
FROM STAGING.transfers_clean;

-- ROW_ID should be unique (one per transfer event)
SELECT 
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT hadm_id) 
        THEN 'ROW_ID is unique' 
        ELSE 'ROW_ID has duplicates' 
    END AS primary_key_check,
    COUNT(*) as total_rows,
    COUNT(DISTINCT row_id) as unique_row_ids
FROM STAGING.transfers_clean;

-- Shows the number of distinct values for each record
SELECT 
    COUNT(DISTINCT row_id) as row_id_distinct,
    COUNT(DISTINCT subject_id) as subject_id_distinct,
    COUNT(DISTINCT hadm_id) as hadm_id_distinct,
    COUNT(DISTINCT icustay_id) as icustay_id_distinct,
    COUNT(DISTINCT dbsource) as dbsource_distinct,
    COUNT(DISTINCT eventtype) as eventtype_distinct,
    COUNT(DISTINCT prev_careunit) as prev_careunit_distinct,
    COUNT(DISTINCT curr_careunit) as curr_careunit_distinct,
    COUNT(DISTINCT prev_wardid) as prev_wardid_distinct,
    COUNT(DISTINCT curr_wardid) as curr_wardid_distinct,
    COUNT(DISTINCT intime) as intime_distinct,
    COUNT(DISTINCT outtime) as outtime_distinct,
    COUNT(DISTINCT los) as los_distinct
FROM STAGING.transfers_clean;

-- Confirm the primary key
SELECT 
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT row_id) 
        THEN 'ROW_ID is unique' 
        ELSE 'ROW_ID has duplicates' 
    END AS row_id_check
FROM STAGING.transfers_clean;

SELECT 
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT icustay_id) 
        THEN 'ICUSTAY_ID is unique' 
        ELSE 'ICUSTAY_ID has duplicates' 
    END AS icustay_id_check
FROM STAGING.transfers_clean;


--DIAGNOSES_ICD
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ROW_ID) AS distinct_row_ids,
    COUNT(DISTINCT SUBJECT_ID) AS distinct_patients,
    COUNT(DISTINCT HADM_ID) AS distinct_admissions,
    COUNT(DISTINCT ICD9_CODE) AS distinct_icd9_codes
FROM DIAGNOSES_ICD;

WITH dupes AS (
    SELECT SUBJECT_ID, HADM_ID, SEQ_NUM, COUNT(*) AS cnt
    FROM GRP5_ASG.RAW.DIAGNOSES_ICD
    GROUP BY SUBJECT_ID, HADM_ID, SEQ_NUM
    HAVING COUNT(*) > 1
)
SELECT *
FROM GRP5_ASG.RAW.DIAGNOSES_ICD d
WHERE EXISTS (
    SELECT 1
    FROM dupes x
    WHERE x.SUBJECT_ID = d.SUBJECT_ID
      AND x.HADM_ID = d.HADM_ID
      AND x.SEQ_NUM = d.SEQ_NUM
);

SELECT ROW_ID, COUNT(*) AS cnt
FROM DIAGNOSES_ICD
GROUP BY ROW_ID
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS null_row_ids
FROM DIAGNOSES_ICD
WHERE ROW_ID IS NULL;

SELECT HADM_ID, SEQ_NUM, COUNT(*) AS cnt
FROM DIAGNOSES_ICD
GROUP BY HADM_ID, SEQ_NUM
HAVING COUNT(*) > 1;

SELECT
    SUM(CASE WHEN ROW_ID IS NULL THEN 1 ELSE 0 END) AS row_id_nulls,
    SUM(CASE WHEN SUBJECT_ID IS NULL THEN 1 ELSE 0 END) AS subject_id_nulls,
    SUM(CASE WHEN HADM_ID IS NULL THEN 1 ELSE 0 END) AS hadm_id_nulls,
    SUM(CASE WHEN SEQ_NUM IS NULL THEN 1 ELSE 0 END) AS seq_num_nulls,
    SUM(CASE WHEN ICD9_CODE IS NULL THEN 1 ELSE 0 END) AS icd9_code_nulls
FROM DIAGNOSES_ICD;

SELECT
    SUBJECT_ID,
    COUNT(DISTINCT HADM_ID) AS admissions_per_patient,
    COUNT(*) AS diagnoses_per_patient
FROM DIAGNOSES_ICD
GROUP BY SUBJECT_ID
ORDER BY diagnoses_per_patient DESC;

SELECT
    HADM_ID,
    COUNT(*) AS diagnoses_per_admission
FROM DIAGNOSES_ICD
GROUP BY HADM_ID
ORDER BY diagnoses_per_admission DESC;

SELECT COUNT(*) AS orphan_admissions
FROM DIAGNOSES_ICD d
LEFT JOIN ADMISSIONS a
ON d.HADM_ID = a.HADM_ID
WHERE a.HADM_ID IS NULL;

SELECT COUNT(*) AS orphan_icd_trimmed
FROM (
    SELECT TRIM(ICD9_CODE) AS ICD9_CODE_TRIM
    FROM DIAGNOSES_ICD
) d
LEFT JOIN DIAGNOSES i
ON d.ICD9_CODE_TRIM = i.ICD9_CODE
WHERE i.ICD9_CODE IS NULL;

--CHARTEVENTS
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ROW_ID) AS unique_rows,
    COUNT(DISTINCT SUBJECT_ID) AS unique_patients,
    COUNT(DISTINCT HADM_ID) AS unique_admissions,
    COUNT(DISTINCT ICUSTAY_ID) AS unique_icu_stays,
    COUNT(DISTINCT ITEMID) AS unique_items
FROM CHARTEVENTS;

WITH dupes AS (
    SELECT ROW_ID, COUNT(*)
    FROM GRP5_ASG.RAW.CHARTEVENTS
    GROUP BY ROW_ID
    HAVING COUNT(*) > 1
)
SELECT *
FROM GRP5_ASG.RAW.CHARTEVENTS c
WHERE EXISTS (
    SELECT 1
    FROM dupes d
    WHERE d.ROW_ID = c.ROW_ID
);

SELECT
    SUM(CASE WHEN ROW_ID IS NULL THEN 1 ELSE 0 END) AS null_row_id,
    SUM(CASE WHEN SUBJECT_ID IS NULL THEN 1 ELSE 0 END) AS null_subject_id,
    SUM(CASE WHEN HADM_ID IS NULL THEN 1 ELSE 0 END) AS null_hadm_id,
    SUM(CASE WHEN ICUSTAY_ID IS NULL THEN 1 ELSE 0 END) AS null_icustay_id,
    SUM(CASE WHEN ITEMID IS NULL THEN 1 ELSE 0 END) AS null_itemid,
    SUM(CASE WHEN CHARTTIME IS NULL THEN 1 ELSE 0 END) AS null_charttime,
    SUM(CASE WHEN STORETIME IS NULL THEN 1 ELSE 0 END) AS null_storetime,
    SUM(CASE WHEN CGID IS NULL THEN 1 ELSE 0 END) AS null_cgid,
    SUM(CASE WHEN VALUE IS NULL THEN 1 ELSE 0 END) AS null_value,
    SUM(CASE WHEN VALUENUM IS NULL THEN 1 ELSE 0 END) AS null_valuenum,
    SUM(CASE WHEN VALUEUOM IS NULL THEN 1 ELSE 0 END) AS null_valueuom,
    SUM(CASE WHEN WARNING IS NULL THEN 1 ELSE 0 END) AS null_warning,
    SUM(CASE WHEN ERROR IS NULL THEN 1 ELSE 0 END) AS null_error,
    SUM(CASE WHEN RESULTSTATUS IS NULL THEN 1 ELSE 0 END) AS null_resultstatus,
    SUM(CASE WHEN STOPPED IS NULL THEN 1 ELSE 0 END) AS null_stopped
FROM CHARTEVENTS;

SELECT
    CASE WHEN COUNT(*) = COUNT(DISTINCT ROW_ID) THEN 'ROW_ID is unique' ELSE 'ROW_ID has duplicates' END AS row_id_check
FROM CHARTEVENTS;

-- 4. Orphan foreign keys check
-- a) HADM_ID not in ADMISSIONS
SELECT COUNT(*) AS orphan_hadm
FROM CHARTEVENTS c
LEFT JOIN ADMISSIONS a
ON c.HADM_ID = a.HADM_ID
WHERE c.HADM_ID IS NOT NULL AND a.HADM_ID IS NULL;

-- b) ICUSTAY_ID not in ICUSTAYS
SELECT COUNT(*) AS orphan_icustay
FROM CHARTEVENTS c
LEFT JOIN ICUSTAYS i
ON c.ICUSTAY_ID = i.ICUSTAY_ID
WHERE c.ICUSTAY_ID IS NOT NULL AND i.ICUSTAY_ID IS NULL;

-- c) SUBJECT_ID not in PATIENTS
SELECT COUNT(*) AS orphan_subject
FROM CHARTEVENTS c
LEFT JOIN PATIENTS p
ON c.SUBJECT_ID = p.SUBJECT_ID
WHERE p.SUBJECT_ID IS NULL;

-- 5. Summary statistics for VALUENUM
SELECT 
    MIN(VALUENUM) AS min_value,
    MAX(VALUENUM) AS max_value,
    AVG(VALUENUM) AS avg_value,
    STDDEV(VALUENUM) AS stddev_value
FROM CHARTEVENTS
WHERE VALUENUM IS NOT NULL;

--SERVICES
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ROW_ID) AS distinct_row_id,
    COUNT(DISTINCT SUBJECT_ID) AS distinct_subject_id,
    COUNT(DISTINCT HADM_ID) AS distinct_hadm_id,
    COUNT(DISTINCT TRANSFERTIME) AS distinct_transfertime,
    COUNT(DISTINCT PREV_SERVICE) AS distinct_prev_service,
    COUNT(DISTINCT CURR_SERVICE) AS distinct_curr_service
FROM SERVICES;

WITH dupes AS (
    SELECT ROW_ID, COUNT(*)
    FROM GRP5_ASG.RAW.SERVICES
    GROUP BY ROW_ID
    HAVING COUNT(*) > 1
)
SELECT *
FROM GRP5_ASG.RAW.SERVICES s
WHERE EXISTS (
    SELECT 1
    FROM dupes d
    WHERE d.ROW_ID = s.ROW_ID
);
SELECT
    SUM(CASE WHEN ROW_ID IS NULL THEN 1 ELSE 0 END) AS null_row_id,
    SUM(CASE WHEN SUBJECT_ID IS NULL THEN 1 ELSE 0 END) AS null_subject_id,
    SUM(CASE WHEN HADM_ID IS NULL THEN 1 ELSE 0 END) AS null_hadm_id,
    SUM(CASE WHEN TRANSFERTIME IS NULL THEN 1 ELSE 0 END) AS null_transfertime,
    SUM(CASE WHEN PREV_SERVICE IS NULL THEN 1 ELSE 0 END) AS null_prev_service,
    SUM(CASE WHEN CURR_SERVICE IS NULL THEN 1 ELSE 0 END) AS null_curr_service
FROM SERVICES;

SELECT ROW_ID, COUNT(*) AS count
FROM SERVICES
GROUP BY ROW_ID
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS null_row_id
FROM SERVICES
WHERE ROW_ID IS NULL;

-- a) SUBJECT_ID not in PATIENTS
SELECT COUNT(*) AS orphan_subject
FROM SERVICES s
LEFT JOIN PATIENTS p
ON s.SUBJECT_ID = p.SUBJECT_ID
WHERE s.SUBJECT_ID IS NOT NULL AND p.SUBJECT_ID IS NULL;

-- b) HADM_ID not in ADMISSIONS
SELECT COUNT(*) AS orphan_hadm
FROM SERVICES s
LEFT JOIN ADMISSIONS a
ON s.HADM_ID = a.HADM_ID
WHERE s.HADM_ID IS NOT NULL AND a.HADM_ID IS NULL;

SELECT HADM_ID, COUNT(*) AS service_count
FROM SERVICES
GROUP BY HADM_ID
ORDER BY service_count DESC;
;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ROW_ID) AS unique_row_id,
    COUNT(DISTINCT ICD9_CODE) AS unique_icd9_code,
    COUNT(DISTINCT SHORT_TITLE) AS unique_short_title,
    COUNT(DISTINCT LONG_TITLE) AS unique_long_title
FROM DIAGNOSES;

SELECT
    SUM(CASE WHEN ROW_ID IS NULL THEN 1 ELSE 0 END) AS null_row_id,
    SUM(CASE WHEN ICD9_CODE IS NULL OR TRIM(ICD9_CODE) = '' THEN 1 ELSE 0 END) AS missing_icd9_code,
    SUM(CASE WHEN SHORT_TITLE IS NULL OR TRIM(SHORT_TITLE) = '' THEN 1 ELSE 0 END) AS missing_short_title,
    SUM(CASE WHEN LONG_TITLE IS NULL OR TRIM(LONG_TITLE) = '' THEN 1 ELSE 0 END) AS missing_long_title
FROM DIAGNOSES;

SELECT
    MIN(LENGTH(SHORT_TITLE)) AS min_short_len,
    MAX(LENGTH(SHORT_TITLE)) AS max_short_len,
    AVG(LENGTH(SHORT_TITLE)) AS avg_short_len,
    MIN(LENGTH(LONG_TITLE)) AS min_long_len,
    MAX(LENGTH(LONG_TITLE)) AS max_long_len,
    AVG(LENGTH(LONG_TITLE)) AS avg_long_len
FROM DIAGNOSES
WHERE SHORT_TITLE IS NOT NULL AND LONG_TITLE IS NOT NULL;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ICD9_CODE) AS distinct_icd9_codes,
    ROUND(COUNT(*) / COUNT(DISTINCT ICD9_CODE), 2) AS avg_rows_per_code
FROM PROCEDURES;

--data profiling procedures

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ROW_ID) AS unique_row_id,
    COUNT(DISTINCT ICD9_CODE) AS unique_icd9_code,
    COUNT(DISTINCT SHORT_TITLE) AS unique_short_title,
    COUNT(DISTINCT LONG_TITLE) AS unique_long_title
FROM PROCEDURES;

SELECT
    SUM(CASE WHEN ROW_ID IS NULL THEN 1 ELSE 0 END) AS null_row_id,
    SUM(CASE WHEN ICD9_CODE IS NULL THEN 1 ELSE 0 END) AS null_icd9_code,
    SUM(CASE WHEN SHORT_TITLE IS NULL OR TRIM(SHORT_TITLE) = '' THEN 1 ELSE 0 END) AS missing_short_title,
    SUM(CASE WHEN LONG_TITLE IS NULL OR TRIM(LONG_TITLE) = '' THEN 1 ELSE 0 END) AS missing_long_title
FROM PROCEDURES;

SELECT ICD9_ID, COUNT(*) AS duplicate_count
FROM PROCEDURES
GROUP BY ICD9_ID
HAVING COUNT(*) > 1;

SELECT ICD9_CODE, COUNT(*) AS duplicate_count
FROM PROCEDURES
GROUP BY ICD9_CODE
HAVING COUNT(*) > 1;
SELECT
    MIN(LENGTH(SHORT_TITLE)) AS min_short_len,
    MAX(LENGTH(SHORT_TITLE)) AS max_short_len,
    AVG(LENGTH(SHORT_TITLE)) AS avg_short_len,
    MIN(LENGTH(LONG_TITLE)) AS min_long_len,
    MAX(LENGTH(LONG_TITLE)) AS max_long_len,
    AVG(LENGTH(LONG_TITLE)) AS avg_long_len
FROM PROCEDURES;

SELECT
    'ROW_ID' AS column_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ROW_ID) AS distinct_values,
    SUM(CASE WHEN ROW_ID IS NULL THEN 1 ELSE 0 END) AS null_count
FROM PROCEDURES

UNION ALL

SELECT
    'ICD9_CODE' AS column_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ICD9_CODE) AS distinct_values,
    SUM(CASE WHEN ICD9_CODE IS NULL THEN 1 ELSE 0 END) AS null_count
FROM PROCEDURES;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ROW_ID) AS distinct_row_id,
    COUNT(DISTINCT ICD9_CODE) AS distinct_icd9_code,
    ROUND(COUNT(DISTINCT ICD9_CODE) / COUNT(*) * 100, 2) AS icd9_uniqueness_pct,
    ROUND(COUNT(*) / COUNT(DISTINCT ICD9_CODE), 2) AS avg_rows_per_code
FROM PROCEDURES;

-- set context
USE ROLE TRAINING_ROLE;
USE WAREHOUSE BULLFROG_WH;
USE DATABASE GRP5_ASG;
USE SCHEMA GRP5_ASG.STAGING;

CREATE SCHEMA IF NOT EXISTS STAGING;
--------------
-- ICUSTAYS
--------------

-- row count
SELECT COUNT(*) FROM RAW.ICUSTAYS;

-- check for null
SELECT
  COUNT_IF(ICUSTAY_ID IS NULL) AS null_icustay,
  COUNT_IF(INTIME IS NULL) AS null_intime,
  COUNT_IF(OUTTIME IS NULL) AS null_outtime
FROM RAW.ICUSTAYS;

-- logical checks
SELECT *
FROM RAW.ICUSTAYS
WHERE OUTTIME < INTIME;=

-- surrogate pk check row_id
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT ROW_ID) AS distinct_row_id,
  SUM(IFF(ROW_ID IS NULL, 1, 0)) AS null_row_id,
  IFF(COUNT(*) = COUNT(DISTINCT ROW_ID) AND SUM(IFF(ROW_ID IS NULL,1,0)) = 0, 'YES', 'NO') AS row_id_is_unique_nonnull
FROM RAW.ICUSTAYS;

-- icustay_id
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT ICUSTAY_ID) AS distinct_icustay_id,
  SUM(IFF(ICUSTAY_ID IS NULL, 1, 0)) AS null_icustay_id,
  IFF(COUNT(*) = COUNT(DISTINCT ICUSTAY_ID) AND SUM(IFF(ICUSTAY_ID IS NULL,1,0)) = 0, 'YES', 'NO') AS icustay_id_is_unique_nonnull
FROM RAW.ICUSTAYS;

-- subject_id cardinality (many icu stays per patient)
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT SUBJECT_ID) AS distinct_subject_id,
  SUM(IFF(SUBJECT_ID IS NULL, 1, 0)) AS null_subject_id,
  (COUNT(*) * 1.0) / NULLIF(COUNT(DISTINCT SUBJECT_ID), 0) AS avg_rows_per_subject
FROM RAW.ICUSTAYS;

-- check for orphan subject_id (0 orphan rows=perfect fk)
SELECT
  COUNT(*) AS orphan_subject_ids
FROM RAW.ICUSTAYS i
LEFT JOIN RAW.PATIENTS p
  ON i.SUBJECT_ID = p.SUBJECT_ID
WHERE p.SUBJECT_ID IS NULL;

-- check for orphan hadm_id
SELECT
  COUNT(*) AS orphan_hadm_ids
FROM RAW.ICUSTAYS i
LEFT JOIN RAW.ADMISSIONS a
  ON i.HADM_ID = a.HADM_ID
WHERE i.HADM_ID IS NOT NULL
  AND a.HADM_ID IS NULL;

-------------------
-- PROCEDURES_ICD
-------------------

-- row count
SELECT COUNT(*) AS total_rows
FROM RAW.PROCEDURES_ICD;

-- check for null
SELECT
  COUNT_IF(SUBJECT_ID IS NULL) AS null_subject_id,
  COUNT_IF(HADM_ID IS NULL) AS null_hadm_id,
  COUNT_IF(ICD9_CODE IS NULL) AS null_icd9_code
FROM RAW.PROCEDURES_ICD;

-- check for duplicates
SELECT
  SUBJECT_ID,
  HADM_ID,
  ICD9_CODE,
  COUNT(*) AS duplicate_count
FROM RAW.PROCEDURES_ICD
GROUP BY SUBJECT_ID, HADM_ID, ICD9_CODE
HAVING COUNT(*) > 1;

-- surrogate pk check
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT ROW_ID) AS distinct_row_id,
  SUM(IFF(ROW_ID IS NULL, 1, 0)) AS null_row_id,
  IFF(COUNT(*) = COUNT(DISTINCT ROW_ID) AND SUM(IFF(ROW_ID IS NULL,1,0)) = 0, 'YES', 'NO') AS row_id_is_unique_nonnull
FROM RAW.PROCEDURES_ICD;

-- subject id fk
SELECT
  COUNT(*) AS orphan_subject_ids
FROM RAW.PROCEDURES_ICD i
LEFT JOIN RAW.PATIENTS p
  ON i.SUBJECT_ID = p.SUBJECT_ID
WHERE p.SUBJECT_ID IS NULL;

-- hadm id fk
SELECT
  COUNT(*) AS orphan_hadm_ids
FROM RAW.PROCEDURES_ICD i
LEFT JOIN RAW.ADMISSIONS a
  ON i.HADM_ID = a.HADM_ID
WHERE i.HADM_ID IS NOT NULL
  AND a.HADM_ID IS NULL;
  
------------
-- CALLOUT
------------
-- row count
SELECT COUNT(*) AS total_rows
FROM RAW.CALLOUT;

-- check for null
SELECT
  COUNT_IF(SUBJECT_ID IS NULL) AS null_subject_id,
  COUNT_IF(HADM_ID IS NULL) AS null_hadm_id,
  COUNT_IF(CALLOUT_STATUS IS NULL) AS null_callout_status,
  COUNT_IF(CREATETIME IS NULL) AS null_createtime
FROM RAW.CALLOUT;

-- logical check 
SELECT *
FROM RAW.CALLOUT
WHERE UPDATETIME < CREATETIME;

SELECT CALLOUT_STATUS, CALLOUT_OUTCOME, COUNT(*) AS count
FROM RAW.CALLOUT
GROUP BY CALLOUT_STATUS, CALLOUT_OUTCOME
ORDER BY count DESC;

-- surrogate pk check
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT ROW_ID) AS distinct_row_id,
  SUM(IFF(ROW_ID IS NULL, 1, 0)) AS null_row_id,
  IFF(COUNT(*) = COUNT(DISTINCT ROW_ID) AND SUM(IFF(ROW_ID IS NULL,1,0)) = 0, 'YES', 'NO') AS row_id_is_unique_nonnull
FROM RAW.CALLOUT;

-- subject id fk
SELECT
  COUNT(*) AS orphan_subject_ids
FROM RAW.CALLOUT c
LEFT JOIN RAW.PATIENTS p
  ON c.SUBJECT_ID = p.SUBJECT_ID
WHERE p.SUBJECT_ID IS NULL;

-- hadm id fk
SELECT
  COUNT(*) AS orphan_hadm_ids
FROM RAW.CALLOUT c
LEFT JOIN RAW.ADMISSIONS a
  ON c.HADM_ID = a.HADM_ID
WHERE c.HADM_ID IS NOT NULL
  AND a.HADM_ID IS NULL;

-- suspend warehouse when not in use 
ALTER WAREHOUSE BULLFROG_WH
SUSPEND;



USE ROLE TRAINING_ROLE;
USE WAREHOUSE CHIPMUNK_WH;
USE DATABASE GRP5_ASG;
USE SCHEMA GRP5_ASG.RAW;

-- PRESCRIPTIONS
-- overview
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ROW_ID) AS distinct_row_id,
    COUNT(DISTINCT HADM_ID) AS distinct_hadm_id,
    COUNT(DISTINCT ICUSTAY_ID) AS distinct_icustay_id,
    COUNT(DISTINCT DRUG) AS distinct_drug,
    COUNT(DISTINCT ROUTE) AS distinct_route,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT HADM_ID), 2) AS avg_prescriptions_per_admission,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT ICUSTAY_ID), 2) AS avg_prescriptions_per_icustay
FROM GRP5_ASG.RAW.PRESCRIPTIONS;

-- duplicates check
WITH duplicate AS (
    SELECT ROW_ID, COUNT(*) 
    FROM GRP5_ASG.RAW.PRESCRIPTIONS
    GROUP BY ROW_ID
    HAVING COUNT(*) > 1
)
SELECT *
FROM GRP5_ASG.RAW.PRESCRIPTIONS s
WHERE EXISTS (
    SELECT 1
    FROM duplicate d
    WHERE d.ROW_ID = s.ROW_ID
);

-- null checks
SELECT 
    SUM(CASE WHEN ROW_ID IS NULL THEN 1 ELSE 0 END) AS null_row_id,
    SUM(CASE WHEN HADM_ID IS NULL THEN 1 ELSE 0 END) AS null_hadm_id,
    SUM(CASE WHEN ICUSTAY_ID IS NULL THEN 1 ELSE 0 END) AS null_icustay_id,
    SUM(CASE WHEN STARTDATE IS NULL THEN 1 ELSE 0 END) AS null_startdate,
    SUM(CASE WHEN ENDDATE IS NULL THEN 1 ELSE 0 END) AS null_enddate,
    SUM(CASE WHEN DRUG IS NULL THEN 1 ELSE 0 END) AS null_drug,
    SUM(CASE WHEN ROUTE IS NULL THEN 1 ELSE 0 END) AS null_route,
    SUM(CASE WHEN DOSE_VAL_RX IS NULL THEN 1 ELSE 0 END) AS null_dose_val_rx
FROM GRP5_ASG.RAW.PRESCRIPTIONS;

-- primary key
SELECT ROW_ID, COUNT(*)
FROM GRP5_ASG.RAW.PRESCRIPTIONS
GROUP BY ROW_ID
HAVING COUNT(*) > 1;

-- foreign key 
SELECT COUNT(*) AS orphan_admissions
FROM GRP5_ASG.RAW.PRESCRIPTIONS p
WHERE NOT EXISTS (
    SELECT 1
    FROM GRP5_ASG.RAW.ADMISSIONS adm
    WHERE p.HADM_ID = adm.HADM_ID
);



-- PROCEDURE EVENTS
-- overview 
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT HADM_ID) AS distinct_hadm_id,
    COUNT(DISTINCT ICUSTAY_ID) AS distinct_icustay_id,
    COUNT(DISTINCT ITEMID) AS distinct_procedure_items,
    COUNT(DISTINCT VALUE) AS distinct_values
FROM GRP5_ASG.RAW.PROCEDUREEVENTS_MV;

-- duplicates check
WITH duplicate AS (
    SELECT ROW_ID, COUNT(*) 
    FROM GRP5_ASG.RAW.PROCEDUREEVENTS_MV
    GROUP BY ROW_ID
    HAVING COUNT(*) > 1
)
SELECT *
FROM GRP5_ASG.RAW.PROCEDUREEVENTS_MV s
WHERE EXISTS (
    SELECT 1
    FROM duplicate d
    WHERE d.ROW_ID = s.ROW_ID
);

-- primary key and null check
SELECT 
    SUM(CASE WHEN ROW_ID IS NULL THEN 1 ELSE 0 END) AS null_row_id,
    SUM(CASE WHEN SUBJECT_ID IS NULL THEN 1 ELSE 0 END) AS null_subject_id,
    SUM(CASE WHEN HADM_ID IS NULL THEN 1 ELSE 0 END) AS null_hadm_id,
    SUM(CASE WHEN ICUSTAY_ID IS NULL THEN 1 ELSE 0 END) AS null_icustay_id,
    SUM(CASE WHEN STARTTIME IS NULL THEN 1 ELSE 0 END) AS null_starttime,
    SUM(CASE WHEN ENDTIME IS NULL THEN 1 ELSE 0 END) AS null_endtime,
    SUM(CASE WHEN ITEMID IS NULL THEN 1 ELSE 0 END) AS null_itemid,
    SUM(CASE WHEN VALUE IS NULL THEN 1 ELSE 0 END) AS null_value,
    SUM(CASE WHEN VALUEUOM IS NULL THEN 1 ELSE 0 END) AS null_valueuom
FROM GRP5_ASG.RAW.PROCEDUREEVENTS_MV;


-- foreign key
SELECT COUNT(*) AS orphan_admissions
FROM GRP5_ASG.RAW.PROCEDUREEVENTS_MV p
WHERE NOT EXISTS (
    SELECT 1
    FROM GRP5_ASG.RAW.ADMISSIONS adm
    WHERE p.HADM_ID = adm.HADM_ID
);

SELECT COUNT(*) AS orphan_icustays
FROM GRP5_ASG.RAW.PROCEDUREEVENTS_MV p
WHERE NOT EXISTS (
    SELECT 1
    FROM GRP5_ASG.RAW.ICUSTAYS icu
    WHERE p.ICUSTAY_ID = icu.ICUSTAY_ID
);

-- suspend warehouse when not in use 
ALTER WAREHOUSE CHIPMUNK_WH
SUSPEND;


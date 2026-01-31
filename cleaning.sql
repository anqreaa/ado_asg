--------------
-- CLEANING
--------------
USE ROLE TRAINING_ROLE;
USE WAREHOUSE BISON_WH;
USE DATABASE GRP5_ASG;
USE SCHEMA GRP5_ASG.STAGING;

-- ADMISSIONS
SELECT DISTINCT insurance
FROM STAGING.admissions_clean;

SELECT DISTINCT religion
FROM STAGING.admissions_clean;

SELECT DISTINCT marital_status
FROM STAGING.admissions_clean;

SELECT DISTINCT discharge_location
FROM STAGING.admissions_clean;

SELECT DISTINCT ethnicity
FROM STAGING.admissions_clean;

SELECT DISTINCT language
FROM STAGING.admissions_clean;


CREATE OR REPLACE TABLE STAGING.admissions_clean AS
SELECT 
    row_id,
    subject_id,
    hadm_id,
    admittime,
    dischtime,
    deathtime,
    admission_type,
    admission_location,

    -- Standardize discharge location
    CASE 
        WHEN discharge_location LIKE '%DEAD/EXPIRED%' THEN 'DEAD'
        ELSE UPPER(discharge_location)
    END AS discharge_location,
    -- Standardize insurance
    CASE 
        WHEN insurance IS NULL THEN 'UNKNOWN'
        ELSE UPPER(insurance)
    END AS insurance,
    -- Standardize language
    CASE 
        WHEN language IS NULL THEN 'UNKNOWN'
        ELSE UPPER(TRIM(LANGUAGE))
    END AS language,
    -- Standardize religion
    CASE 
        WHEN religion LIKE '%UNOBTAINABLE%' OR religion LIKE '%NOT SPECIFIED%' THEN 'UNKNOWN'
        WHEN religion IS NULL THEN 'UNKNOWN'
        ELSE UPPER(TRIM(religion))
    END AS religion,
    -- Standardize marital status
    CASE 
        WHEN marital_status LIKE '%UNKNOWN%' OR marital_status IS NULL THEN 'UNKNOWN'
        ELSE UPPER(TRIM(marital_status))
    END AS marital_status,
    -- Standardize ethnicity
    CASE 
        WHEN ethnicity LIKE '%HISPANIC%' OR ethnicity LIKE '%LATINO%' THEN 'HISPANIC/LATINO'
        WHEN ethnicity LIKE '%BLACK%' OR ethnicity LIKE '%AFRICAN%' THEN 'BLACK/AFRICAN AMERICAN'
        WHEN ethnicity LIKE '%ASIAN%' THEN 'ASIAN'
        WHEN ethnicity LIKE '%WHITE%' THEN 'WHITE'
        WHEN ethnicity LIKE '%AMERICAN INDIAN%' OR ethnicity LIKE '%ALASKA NATIVE%' THEN 'AMERICAN INDIAN/ALASKA NATIVE'
        WHEN ethnicity IN ('UNABLE TO OBTAIN', 'UNKNOWN/NOT SPECIFIED') THEN 'UNKNOWN'
        WHEN ethnicity = 'OTHER' THEN 'OTHER'
        ELSE 'UNKNOWN'
    END AS ethnicity,
    edregtime,
    edouttime,
    diagnosis,
    hospital_expire_flag,
    has_chartevents_data
FROM RAW.admissions;


SELECT * 
FROM STAGING.admissions_clean
LIMIT 10;


GRP5_ASG.STAGING.ADMISSIONS_CLEAN
LIMIT 10;

-- after data has been finalised
CREATE OR REPLACE TABLE CLEAN.ADMISSIONS AS
SELECT * FROM STAGING.admissions_clean;

-- data foreign key check
SELECT 
    a.subject_id,
    COUNT(*) AS admission_count
FROM admissions a
LEFT JOIN patients p
    ON a.subject_id = p.subject_id
WHERE p.subject_id IS NULL
GROUP BY a.subject_id;


-- PATIENTS
PATIENT CLEAN
-- See first 10 rows
SELECT * 
FROM STAGING.patients_clean
LIMIT 10;

-- Find cases where dates don't match
SELECT * 
FROM STAGING.patients_clean
   WHERE dod != dod_hosp OR dod != dod_ssn;

CREATE OR REPLACE TABLE STAGING.PATIENTS_CLEAN AS
SELECT * EXCLUDE (dod_hosp, dod_ssn)
FROM RAW.patients;

CREATE OR REPLACE TABLE CLEAN.PATIENTS AS
SELECT *
FROM STAGING.patients_clean;


SELECT * 
FROM CLEAN.patients
LIMIT 10;

-- TRANSFERS
SELECT * 
FROM STAGING.transfers_clean
LIMIT 10;

-- Find and review records where outtime < intime
SELECT *
FROM STAGING.transfers_clean
WHERE outtime < intime;

-- capitalise the text data to standardise with the other tables
UPDATE STAGING.TRANSFERS_CLEAN
SET 
    dbsource = UPPER(TRIM(dbsource)),
    eventtype = UPPER(TRIM(eventtype)),
    prev_careunit = UPPER(TRIM(prev_careunit)),
    curr_careunit = UPPER(TRIM(curr_careunit));




CREATE OR REPLACE TABLE CLEAN.TRANSFERS AS
SELECT *
FROM STAGING.transfers_clean;


-- check for foreign key
-- 1) Check orphan SUBJECT_IDs in TRANSFERS (should be 0)
SELECT t.subject_id, COUNT(*) AS transfer_rows
FROM transfers t
LEFT JOIN patients p
  ON t.subject_id = p.subject_id
WHERE p.subject_id IS NULL
GROUP BY t.subject_id;

-- 2) Check orphan HADM_IDs in TRANSFERS (should be 0 if not null)
SELECT t.hadm_id, COUNT(*) AS transfer_rows
FROM transfers t
LEFT JOIN admissions a
  ON t.hadm_id = a.hadm_id
WHERE t.hadm_id IS NOT NULL
  AND a.hadm_id IS NULL
GROUP BY t.hadm_id;

-- 3) Check orphan ICUSTAY_IDs in TRANSFERS (often some can be null)
SELECT t.icustay_id, COUNT(*) AS transfer_rows
FROM transfers t
LEFT JOIN icustays i
  ON t.icustay_id = i.icustay_id
WHERE t.icustay_id IS NOT NULL
  AND i.icustay_id IS NULL
GROUP BY t.icustay_id;

--CHARTEVENTS
CREATE OR REPLACE TABLE CHARTEVENTS_CLEAN AS
SELECT
    ROW_ID,                       -- Primary key no nulls
    SUBJECT_ID,                   -- Foreign key to patients
    HADM_ID,                      -- Foreign key to admissions
    ICUSTAY_ID,                   -- May be NULL for non ICU events
    ITEMID,
    CHARTTIME,
    STORETIME,
    CGID,
    TRIM(VALUE) AS VALUE,         -- trim spaces
    VALUENUM,                     -- numeric
    TRIM(VALUEUOM) AS VALUEUOM,   -- trim spaces
    WARNING,
    ERROR,
    UPPER(TRIM(RESULTSTATUS)) AS RESULTSTATUS,  -- standardize text
    UPPER(TRIM(STOPPED)) AS STOPPED             -- standardize text
FROM GRP5_ASG.RAW.CHARTEVENTS
-- Keep only valid rows for analysis
WHERE ROW_ID IS NOT NULL
  AND SUBJECT_ID IS NOT NULL
  AND HADM_ID IS NOT NULL

SELECT 
    SUM(CASE WHEN ROW_ID IS NULL THEN 1 ELSE 0 END) AS row_id_nulls,
    SUM(CASE WHEN SUBJECT_ID IS NULL THEN 1 ELSE 0 END) AS subject_id_nulls,
    SUM(CASE WHEN HADM_ID IS NULL THEN 1 ELSE 0 END) AS hadm_id_nulls,
    SUM(CASE WHEN ICUSTAY_ID IS NULL THEN 1 ELSE 0 END) AS icustay_id_nulls
FROM CHARTEVENTS_CLEAN;

SELECT
    SUM(CASE WHEN VALUE IS NOT NULL AND VALUE <> TRIM(VALUE) THEN 1 ELSE 0 END) AS value_needs_trim,
    SUM(CASE WHEN VALUEUOM IS NOT NULL AND VALUEUOM <> TRIM(VALUEUOM) THEN 1 ELSE 0 END) AS valueuom_needs_trim,
    SUM(CASE WHEN RESULTSTATUS IS NOT NULL AND RESULTSTATUS <> TRIM(RESULTSTATUS) THEN 1 ELSE 0 END) AS resultstatus_needs_trim,
    SUM(CASE WHEN STOPPED IS NOT NULL AND STOPPED <> TRIM(STOPPED) THEN 1 ELSE 0 END) AS stopped_needs_trim
FROM CHARTEVENTS_CLEAN;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT SUBJECT_ID) AS unique_patients,
    COUNT(DISTINCT HADM_ID) AS unique_admissions,
    COUNT(DISTINCT ICUSTAY_ID) AS unique_icu_stays
FROM CHARTEVENTS_CLEAN;

SELECT *
FROM STAGING.CHARTEVENTS_CLEAN
LIMIT 10;

--DIAGNOSES_ICD
CREATE OR REPLACE TABLE DIAGNOSES_ICD_CLEAN AS
SELECT 
    ROW_ID,                       -- Primary key no nulls
    SUBJECT_ID,                   -- Foreign key to patients
    HADM_ID,                      -- Foreign key to admissions
    SEQ_NUM,
    UPPER(TRIM(ICD9_CODE)) AS ICD9_CODE
FROM GRP5_ASG.RAW.DIAGNOSES_ICD;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ROW_ID) AS distinct_row_id,
    COUNT(DISTINCT SUBJECT_ID) AS unique_patients,
    COUNT(DISTINCT HADM_ID) AS unique_admissions,

    SUM(CASE WHEN ROW_ID IS NULL THEN 1 ELSE 0 END) AS row_id_nulls,
    SUM(CASE WHEN SUBJECT_ID IS NULL THEN 1 ELSE 0 END) AS subject_id_nulls,
    SUM(CASE WHEN HADM_ID IS NULL THEN 1 ELSE 0 END) AS hadm_id_nulls,
    SUM(CASE WHEN ICD9_CODE IS NULL THEN 1 ELSE 0 END) AS icd9_code_nulls,
    
    SUM(CASE WHEN ICD9_CODE IS NOT NULL AND ICD9_CODE <> TRIM(ICD9_CODE) THEN 1 ELSE 0 END) AS icd9_codes_trim
FROM DIAGNOSES_ICD_CLEAN;

SELECT *
FROM STAGING.DIAGNOSES_ICD_CLEAN;

--SERVICES
CREATE OR REPLACE TABLE STAGING.SERVICES_CLEAN AS
SELECT
    ROW_ID,                       -- Primary key no nulls
    SUBJECT_ID,                   -- Foreign key to patients
    HADM_ID,                      -- Foreign key to admissions
    TRANSFERTIME,
    UPPER(TRIM(PREV_SERVICE)) AS PREV_SERVICE,  --Standardize text
    UPPER(TRIM(CURR_SERVICE)) AS CURR_SERVICE   --Standardize text
FROM GRP5_ASG.RAW.SERVICES;

SELECT
    (SELECT COUNT(*) FROM GRP5_ASG.RAW.SERVICES) AS original_count,
    (SELECT COUNT(*) FROM STAGING.SERVICES_CLEAN) AS cleaned_count;

SELECT 
    SUM(CASE WHEN ROW_ID IS NULL THEN 1 ELSE 0 END) AS row_id_nulls,
    SUM(CASE WHEN SUBJECT_ID IS NULL THEN 1 ELSE 0 END) AS subject_id_nulls,
    SUM(CASE WHEN HADM_ID IS NULL THEN 1 ELSE 0 END) AS hadm_id_nulls
FROM STAGING.SERVICES_CLEAN;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT SUBJECT_ID) AS unique_patients,
    COUNT(DISTINCT HADM_ID) AS unique_admissions,
    COUNT(DISTINCT ROW_ID) AS unique_rows,
    SUM(CASE WHEN PREV_SERVICE IS NOT NULL AND PREV_SERVICE <> TRIM(PREV_SERVICE) THEN 1 ELSE 0 END) AS prev_service_needs_trim,
    SUM(CASE WHEN CURR_SERVICE IS NOT NULL AND CURR_SERVICE <> TRIM(CURR_SERVICE) THEN 1 ELSE 0 END) AS curr_service_needs_trim
FROM STAGING.SERVICES_CLEAN;

SELECT *
FROM STAGING.SERVICES_CLEAN
LIMIT 10;


--Upload tables to clean schema
USE ROLE TRAINING_ROLE;
USE WAREHOUSE BISON_WH;
USE DATABASE GRP5_ASG;
USE SCHEMA GRP5_ASG.CLEAN;

CREATE OR REPLACE TABLE CHARTEVENTS AS
SELECT *
FROM GRP5_ASG.STAGING.CHARTEVENTS_CLEAN;

CREATE OR REPLACE TABLE DIAGNOSES_ICD AS
SELECT *
FROM GRP5_ASG.STAGING.DIAGNOSES_ICD_CLEAN;

CREATE OR REPLACE TABLE SERVICES AS
SELECT *

FROM GRP5_ASG.STAGING.SERVICES_CLEAN;
--cleaning
USE ROLE TRAINING_ROLE;
USE WAREHOUSE FOX_WH;
USE DATABASE GRP5_ASG;
USE SCHEMA GRP5_ASG.STAGING;
--Clean Diagnoses
CREATE OR REPLACE TABLE GRP5_ASG.STAGING.DIAGNOSES_CLEAN AS
SELECT
    ROW_ID,
    UPPER(TRIM(ICD9_CODE)) AS ICD9_CODE,
    INITCAP(TRIM(SHORT_TITLE)) AS SHORT_TITLE,
    INITCAP(TRIM(LONG_TITLE)) AS LONG_TITLE
FROM DIAGNOSES;
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ROW_ID) AS unique_rowid,
    COUNT(DISTINCT ICD9_CODE) AS unique_icd9,
    SUM(CASE WHEN TRIM(ICD9_CODE) <> ICD9_CODE THEN 1 ELSE 0 END) AS icd9_has_spaces,
    SUM(CASE WHEN TRIM(SHORT_TITLE) <> SHORT_TITLE THEN 1 ELSE 0 END) AS short_title_has_spaces,
    SUM(CASE WHEN TRIM(LONG_TITLE) <> LONG_TITLE THEN 1 ELSE 0 END) AS long_title_has_spaces
FROM DIAGNOSES;

--cleaning procedures
CREATE OR REPLACE TABLE GRP5_ASG.STAGING.PROCEDURES_CLEAN AS
SELECT
    ROW_ID,
    ICD9_CODE,
    INITCAP(TRIM(SHORT_TITLE)) AS SHORT_TITLE,
    INITCAP(TRIM(LONG_TITLE)) AS LONG_TITLE
FROM PROCEDURES;
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ROW_ID) AS unique_rowid,
    COUNT(DISTINCT ICD9_CODE) AS unique_icd9,
    SUM(CASE WHEN TRIM(SHORT_TITLE) <> SHORT_TITLE THEN 1 ELSE 0 END) AS short_title_needs_trim,
    SUM(CASE WHEN TRIM(LONG_TITLE) <> LONG_TITLE THEN 1 ELSE 0 END) AS long_title_needs_trim
FROM PROCEDURES;

CREATE OR REPLACE TABLE GRP5_ASG.CLEAN.PROCEDURES AS
SELECT * FROM GRP5_ASG.STAGING.PROCEDURES_CLEAN;

CREATE OR REPLACE TABLE GRP5_ASG.CLEAN.DIAGNOSIS AS
SELECT * FROM GRP5_ASG.STAGING.DIAGNOSES_CLEAN;

-- set context
USE ROLE TRAINING_ROLE;
USE WAREHOUSE BULLFROG_WH;
USE DATABASE GRP5_ASG;
USE SCHEMA GRP5_ASG.STAGING;

--------------
-- ICUSTAYS
--------------

CREATE OR REPLACE TABLE GRP5_ASG.STAGING.ICUSTAYS_CLEAN AS
SELECT *
FROM GRP5_ASG.RAW.ICUSTAYS
WHERE ICUSTAY_ID IS NOT NULL
  AND INTIME IS NOT NULL
  AND OUTTIME IS NOT NULL
  AND OUTTIME >= INTIME;

-- Row count comparison
SELECT COUNT(*) AS raw_rows FROM GRP5_ASG.RAW.ICUSTAYS;
SELECT COUNT(*) AS clean_rows FROM GRP5_ASG.STAGING.ICUSTAYS_CLEAN;

-- Should be 0 after cleaning
SELECT COUNT(*) AS invalid_time_rows
FROM GRP5_ASG.STAGING.ICUSTAYS_CLEAN
WHERE OUTTIME < INTIME;

-- Promote to CLEAN
CREATE OR REPLACE TABLE GRP5_ASG.CLEAN.ICUSTAYS AS
SELECT * FROM GRP5_ASG.STAGING.ICUSTAYS_CLEAN;

--------------------
-- PROCEDURES_ICD
--------------------

CREATE OR REPLACE TABLE GRP5_ASG.STAGING.PROCEDURES_ICD_CLEAN AS
SELECT *
FROM GRP5_ASG.RAW.PROCEDURES_ICD
WHERE ICD9_CODE IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY SUBJECT_ID, HADM_ID, ICD9_CODE 
  ORDER BY SEQ_NUM NULLS LAST, ROW_ID // chooses which one to keep
) = 1;

-- duplicate check (should return 0 rows)
SELECT SUBJECT_ID, HADM_ID, ICD9_CODE, COUNT(*) AS dup_count
FROM GRP5_ASG.STAGING.PROCEDURES_ICD_CLEAN
GROUP BY SUBJECT_ID, HADM_ID, ICD9_CODE
HAVING COUNT(*) > 1;

-- promote to CLEAN
CREATE OR REPLACE TABLE GRP5_ASG.CLEAN.PROCEDURES_ICD AS
SELECT * FROM GRP5_ASG.STAGING.PROCEDURES_ICD_CLEAN;

-------------
-- CALLOUT
-------------

CREATE OR REPLACE TABLE GRP5_ASG.STAGING.CALLOUT_CLEAN AS
SELECT *
FROM GRP5_ASG.RAW.CALLOUT
WHERE CALLOUT_STATUS IS NOT NULL
  AND CREATETIME IS NOT NULL
  AND (UPDATETIME IS NULL OR UPDATETIME >= CREATETIME);

-- Row count comparison
SELECT COUNT(*) AS raw_rows FROM GRP5_ASG.RAW.CALLOUT;
SELECT COUNT(*) AS clean_rows FROM GRP5_ASG.STAGING.CALLOUT_CLEAN;

-- 0 after cleaning?
SELECT COUNT(*) AS invalid_time_rows
FROM GRP5_ASG.STAGING.CALLOUT_CLEAN
WHERE UPDATETIME < CREATETIME;

-- promote to CLEAN
CREATE OR REPLACE TABLE GRP5_ASG.CLEAN.CALLOUT AS
SELECT * FROM GRP5_ASG.STAGING.CALLOUT_CLEAN;

SHOW TABLES IN SCHEMA GRP5_ASG.STAGING;
SHOW TABLES IN SCHEMA GRP5_ASG.CLEAN;

------------------------------------------------------------
USE ROLE TRAINING_ROLE;
USE WAREHOUSE CHIPMUNK_WH;
USE DATABASE GRP5_ASG;

-- PRESCRIPTION , staging
-- only with essential columns
CREATE OR REPLACE TABLE GRP5_ASG.STAGING.PRESCRIPTIONS_CLEAN AS
SELECT 
    ROW_ID,
    HADM_ID,
    ICUSTAY_ID,
    STARTDATE,
    ENDDATE,
    DRUG,
    ROUTE,
    DOSE_VAL_RX,
    DOSE_UNIT_RX
FROM GRP5_ASG.RAW.PRESCRIPTIONS
WHERE ROW_ID IS NOT NULL
  AND HADM_ID IS NOT NULL
  AND STARTDATE IS NOT NULL
  AND DRUG IS NOT NULL
  AND ROUTE IS NOT NULL;

-- null check
SELECT COUNT(*) AS invalid_rows
FROM GRP5_ASG.STAGING.PRESCRIPTIONS_CLEAN
WHERE ROW_ID IS NULL;

--duplicate check
SELECT ROW_ID, COUNT(*)
FROM GRP5_ASG.STAGING.PRESCRIPTIONS_CLEAN
WHERE ROW_ID IS NOT NULL
GROUP BY ROW_ID
HAVING COUNT(*) > 1;


-- Remove records where STARTDATE occurs after ENDDATE (illogical)
DELETE FROM GRP5_ASG.STAGING.PRESCRIPTIONS_CLEAN
WHERE ENDDATE IS NOT NULL 
  AND STARTDATE > ENDDATE;


-- check foreign keys and validate again
SELECT COUNT(*) AS orphan_admissions
FROM GRP5_ASG.STAGING.PRESCRIPTIONS_CLEAN p
WHERE NOT EXISTS (
    SELECT 1
    FROM GRP5_ASG.RAW.ADMISSIONS adm
    WHERE p.HADM_ID = adm.HADM_ID
);

-- when done promote to final schema
CREATE OR REPLACE TABLE GRP5_ASG.CLEAN.PRESCRIPTIONS AS
SELECT 
    ROW_ID,
    HADM_ID,
    ICUSTAY_ID,
    STARTDATE,
    ENDDATE,
    DRUG,
    ROUTE,
    DOSE_VAL_RX,
    DOSE_UNIT_RX
FROM GRP5_ASG.STAGING.PRESCRIPTIONS_CLEAN;


---- PROCEDURE EVENTS ----
-- create into staging
CREATE OR REPLACE TABLE GRP5_ASG.STAGING.PROCEDUREEVENTS_MV_CLEAN AS
SELECT 
    ROW_ID,
    SUBJECT_ID,
    HADM_ID,
    ICUSTAY_ID,
    STARTTIME,
    ENDTIME,
    ITEMID,
    VALUE,
    VALUEUOM
FROM GRP5_ASG.RAW.PROCEDUREEVENTS_MV
WHERE ROW_ID IS NOT NULL
  AND SUBJECT_ID IS NOT NULL
  AND HADM_ID IS NOT NULL
  AND ICUSTAY_ID IS NOT NULL
  AND STARTTIME IS NOT NULL
  AND ITEMID IS NOT NULL;

-- data validation, ensure no data is lost
SELECT 
    (SELECT COUNT(*) FROM GRP5_ASG.RAW.PROCEDUREEVENTS_MV) AS raw_count,
    (SELECT COUNT(*) FROM GRP5_ASG.STAGING.PROCEDUREEVENTS_MV_CLEAN) AS staging_clean_count,
    CASE 
        WHEN (SELECT COUNT(*) FROM GRP5_ASG.RAW.PROCEDUREEVENTS_MV) = 
             (SELECT COUNT(*) FROM GRP5_ASG.STAGING.PROCEDUREEVENTS_MV_CLEAN)
        THEN 'No data loss'
        ELSE 'There is a data loss'
    END AS validation_status;

-- Remove records where STARTTIME occurs after ENDTIME (illogical)
DELETE FROM GRP5_ASG.STAGING.PROCEDUREEVENTS_MV_CLEAN
WHERE ENDTIME IS NOT NULL 
  AND STARTTIME > ENDTIME;

-- create into clean schema
CREATE OR REPLACE TABLE GRP5_ASG.CLEAN.PROCEDUREEVENTS_MV AS
SELECT 
    ROW_ID,
    SUBJECT_ID,
    HADM_ID,
    ICUSTAY_ID,
    STARTTIME,
    ENDTIME,
    ITEMID,
    VALUE,
    VALUEUOM
FROM GRP5_ASG.STAGING.PROCEDUREEVENTS_MV_CLEAN;






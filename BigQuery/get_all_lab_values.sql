-- Cohort definition (same as before)
WITH fever AS (
  SELECT DISTINCT hadm_id, subject_id
  FROM `physionet-data.mimiciv_3_1_icu.chartevents`
  WHERE itemid IN (223762)  -- Temperature (°C)
    AND valuenum >= 38.0
),
antibiotics AS (
  SELECT DISTINCT hadm_id, subject_id
  FROM `physionet-data.mimiciv_3_1_derived.antibiotic`
),
cancer AS (
  SELECT DISTINCT hadm_id, subject_id
  FROM `physionet-data.mimiciv_3_1_hosp.diagnoses_icd`
  WHERE REGEXP_CONTAINS(
    icd_code,
    r'(?i)^(' ||
      -- ICD-9 malignant (140–199)
      '14[0-9]|15[0-9]|16[0-9]|17[0-9]|18[0-9]|19[0-9]|' ||
      -- ICD-9 hematologic (200–209)
      '20[0-9]|' ||
      -- ICD-9 benign / uncertain (210–239)
      '21[0-9]|22[0-9]|23[0-9]|24[0-9]|25[0-9]|26[0-9]|27[0-9]|28[0-9]|29[0-9]|' ||
      -- ICD-10 malignant & uncertain (C00–C99, D0x, D3x, D4x)
      'C[0-9]{2}|D0[0-9]|D3[0-9]|D4[0-9]' ||
    ')'
  )
),
adult_cohort AS (
  SELECT DISTINCT f.hadm_id, f.subject_id
  FROM fever f
  JOIN antibiotics a USING (hadm_id, subject_id)
  JOIN cancer c USING (subject_id)
  JOIN `physionet-data.mimiciv_3_1_hosp.admissions` adm
    ON f.hadm_id = adm.hadm_id
  JOIN `physionet-data.mimiciv_3_1_hosp.patients` p
    ON adm.subject_id = p.subject_id
  WHERE (EXTRACT(YEAR FROM adm.admittime) - (p.anchor_year - p.anchor_age)) >= 18
),

-- Get laboratory measurements for those admissions
--  Exclude values with data entry delay > 2 hours
labs AS (
  SELECT
    le.subject_id,
    le.hadm_id,
    le.charttime,
    le.storetime,
    CASE
      WHEN le.itemid = 50912 THEN 'Creatinine (mg/dL)'
      WHEN le.itemid = 50885 THEN 'Bilirubin (mg/dL)'
      WHEN le.itemid = 50889 THEN 'CRP (mg/L)'
      WHEN le.itemid = 51300 THEN 'Leukocytes (10^9/L)'
      WHEN le.itemid = 51222 THEN 'Hemoglobin (g/dL)'
    END AS variable,
    le.valuenum AS value,
    TIMESTAMP_DIFF(le.storetime, le.charttime, MINUTE) / 60.0 AS entry_delay_hours
  FROM `physionet-data.mimiciv_3_1_hosp.labevents` le
  JOIN adult_cohort ac
    ON le.hadm_id = ac.hadm_id
  WHERE le.itemid IN (50912, 50885, 50889, 51300, 51222)
    AND le.valuenum IS NOT NULL
    AND le.charttime IS NOT NULL
    AND le.storetime IS NOT NULL
    --Exclude delays > 2 hours
    AND TIMESTAMP_DIFF(le.storetime, le.charttime, HOUR) <= 2
)

-- Output all labs
SELECT *
FROM labs
ORDER BY hadm_id, charttime;

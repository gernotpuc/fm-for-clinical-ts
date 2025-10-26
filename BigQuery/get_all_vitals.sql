-- 1️⃣ Define cohort (fever + antibiotics + cancer + adult)
WITH fever AS (
  SELECT DISTINCT hadm_id, subject_id
  FROM `physionet-data.mimiciv_3_1_icu.chartevents`
  WHERE itemid IN (223762)      -- Temperature in °C
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

-- 2️⃣ Get vital sign measurements for those admissions
--     ➕ Exclude delayed entries (> 2 hours)
vitals AS (
  SELECT
    ce.subject_id,
    ce.hadm_id,
    ce.charttime,
    ce.storetime,
    CASE
      WHEN ce.itemid = 223762 THEN 'Temperature (°C)'
      WHEN ce.itemid = 220277 THEN 'SpO₂ (%)'
      WHEN ce.itemid = 220181 THEN 'MAP (mmHg)'
      WHEN ce.itemid = 220045 THEN 'Heart Rate (bpm)'
    END AS variable,
    ce.valuenum AS value,
    TIMESTAMP_DIFF(ce.storetime, ce.charttime, MINUTE) / 60.0 AS entry_delay_hours
  FROM `physionet-data.mimiciv_3_1_icu.chartevents` ce
  JOIN adult_cohort ac
    ON ce.hadm_id = ac.hadm_id
  WHERE ce.itemid IN (223762, 220277, 220181, 220045)
    AND ce.valuenum IS NOT NULL
    AND ce.charttime IS NOT NULL
    AND ce.storetime IS NOT NULL
    -- 🚫 Exclude entries delayed > 2 hours
    AND TIMESTAMP_DIFF(ce.storetime, ce.charttime, HOUR) <= 2
)

-- 3️⃣ Output all time series
SELECT *
FROM vitals
ORDER BY hadm_id, charttime;

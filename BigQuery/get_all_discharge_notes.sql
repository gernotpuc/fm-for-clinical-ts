-- 1️⃣ Define your cohort
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
  WHERE REGEXP_CONTAINS(icd_code, r'^(C|D0|D3|D4|1[4-9][0-9])')
),
adult_cohort AS (
  SELECT DISTINCT f.hadm_id, f.subject_id
  FROM fever f
  JOIN antibiotics a USING (hadm_id, subject_id)
  JOIN cancer c USING (hadm_id, subject_id)
  JOIN `physionet-data.mimiciv_3_1_hosp.admissions` adm
    ON f.hadm_id = adm.hadm_id
  JOIN `physionet-data.mimiciv_3_1_hosp.patients` p
    ON adm.subject_id = p.subject_id
  WHERE (EXTRACT(YEAR FROM adm.admittime) - (p.anchor_year - p.anchor_age)) >= 18
)

-- 2️⃣ Get discharge notes for those admissions
SELECT
  dn.subject_id,
  dn.hadm_id,
  dn.charttime,
  dn.text AS discharge_summary
FROM `physionet-data.mimiciv_note.discharge` dn
JOIN adult_cohort ac
  ON dn.hadm_id = ac.hadm_id
ORDER BY dn.hadm_id;

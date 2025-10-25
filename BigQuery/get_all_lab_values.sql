-- 1️⃣ Cohort definition (same as before)
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
  #WHERE REGEXP_CONTAINS(icd_code, r'^(C|D0|D3|D4|1[4-9][0-9])')
  WHERE (
        icd_code LIKE '140%'  -- ICD-9 malignant neoplasms
     OR icd_code LIKE '141%'
     OR icd_code LIKE '142%'
     OR icd_code LIKE '143%'
     OR icd_code LIKE '144%'
     OR icd_code LIKE '145%'
     OR icd_code LIKE '146%'
     OR icd_code LIKE '147%'
     OR icd_code LIKE '148%'
     OR icd_code LIKE '149%'
     OR icd_code LIKE '150%'
     OR icd_code LIKE '151%'
     OR icd_code LIKE '152%'
     OR icd_code LIKE '153%'
     OR icd_code LIKE '154%'
     OR icd_code LIKE '155%'
     OR icd_code LIKE '156%'
     OR icd_code LIKE '157%'
     OR icd_code LIKE '158%'
     OR icd_code LIKE '159%'
     OR icd_code LIKE '160%'
     OR icd_code LIKE '161%'
     OR icd_code LIKE '162%'
     OR icd_code LIKE '163%'
     OR icd_code LIKE '164%'
     OR icd_code LIKE '165%'
     OR icd_code LIKE '166%'
     OR icd_code LIKE '167%'
     OR icd_code LIKE '168%'
     OR icd_code LIKE '169%'
     OR icd_code LIKE '170%'
     OR icd_code LIKE '171%'
     OR icd_code LIKE '172%'
     OR icd_code LIKE '173%'
     OR icd_code LIKE '174%'
     OR icd_code LIKE '175%'
     OR icd_code LIKE '176%'
     OR icd_code LIKE '177%'
     OR icd_code LIKE '178%'
     OR icd_code LIKE '179%'
     OR icd_code LIKE '180%'
     OR icd_code LIKE '181%'
     OR icd_code LIKE '182%'
     OR icd_code LIKE '183%'
     OR icd_code LIKE '184%'
     OR icd_code LIKE '185%'
     OR icd_code LIKE '186%'
     OR icd_code LIKE '187%'
     OR icd_code LIKE '188%'
     OR icd_code LIKE '189%'
     OR icd_code LIKE '190%'
     OR icd_code LIKE '191%'
     OR icd_code LIKE '192%'
     OR icd_code LIKE '193%'
     OR icd_code LIKE '194%'
     OR icd_code LIKE '195%'
     OR icd_code LIKE '196%'
     OR icd_code LIKE '197%'
     OR icd_code LIKE '198%'
     OR icd_code LIKE '199%'
     OR icd_code LIKE '200%'  -- Lymphoma
     OR icd_code LIKE '201%'
     OR icd_code LIKE '202%'
     OR icd_code LIKE '203%'
     OR icd_code LIKE '204%'
     OR icd_code LIKE '205%'
     OR icd_code LIKE '206%'
     OR icd_code LIKE '207%'
     OR icd_code LIKE '208%'
     OR icd_code LIKE '209%'
     OR icd_code LIKE '210%'  -- Benign/malignant neoplasms
     OR icd_code LIKE '211%'
     OR icd_code LIKE '212%'
     OR icd_code LIKE '213%'
     OR icd_code LIKE '214%'
     OR icd_code LIKE '215%'
     OR icd_code LIKE '216%'
     OR icd_code LIKE '217%'
     OR icd_code LIKE '218%'
     OR icd_code LIKE '219%'
     OR icd_code LIKE '220%'
     OR icd_code LIKE '221%'
     OR icd_code LIKE '222%'
     OR icd_code LIKE '223%'
     OR icd_code LIKE '224%'
     OR icd_code LIKE '225%'
     OR icd_code LIKE '226%'
     OR icd_code LIKE '227%'
     OR icd_code LIKE '228%'
     OR icd_code LIKE '229%'
     OR icd_code LIKE '230%'
     OR icd_code LIKE '231%'
     OR icd_code LIKE '232%'
     OR icd_code LIKE '233%'
     OR icd_code LIKE '234%'
     OR icd_code LIKE '235%'
     OR icd_code LIKE '236%'
     OR icd_code LIKE '237%'
     OR icd_code LIKE '238%'
     OR icd_code LIKE '239%'
     OR icd_code LIKE 'C%'    -- ICD-10 malignant neoplasms
     OR icd_code LIKE 'D0%'   -- some benign / uncertain neoplasms
     OR icd_code LIKE 'D3%'
     OR icd_code LIKE 'D4%'
  )
),
adult_cohort AS (
  SELECT DISTINCT f.hadm_id, f.subject_id
  FROM fever f
  JOIN antibiotics a USING (hadm_id, subject_id)
  #JOIN cancer c USING (hadm_id, subject_id)
  JOIN cancer c USING (subject_id)

  JOIN `physionet-data.mimiciv_3_1_hosp.admissions` adm
    ON f.hadm_id = adm.hadm_id
  JOIN `physionet-data.mimiciv_3_1_hosp.patients` p
    ON adm.subject_id = p.subject_id
  WHERE (EXTRACT(YEAR FROM adm.admittime) - (p.anchor_year - p.anchor_age)) >= 18
),

-- 2️⃣ Get laboratory measurements for those admissions
labs AS (
  SELECT
    le.subject_id,
    le.hadm_id,
    le.charttime,
    CASE
      WHEN le.itemid = 50912 THEN 'Creatinine (mg/dL)'
      WHEN le.itemid = 50885 THEN 'Bilirubin (mg/dL)'
      WHEN le.itemid = 50889 THEN 'CRP (mg/L)'
      WHEN le.itemid = 51300 THEN 'Leukocytes (10^9/L)'
      WHEN le.itemid = 51222 THEN 'Hemoglobin (g/dL)'
    END AS variable,
    le.valuenum AS value
  FROM `physionet-data.mimiciv_3_1_hosp.labevents` le
  JOIN adult_cohort ac
    ON le.hadm_id = ac.hadm_id
  WHERE le.itemid IN (50912, 50885, 50889, 51300, 51222)
    AND le.valuenum IS NOT NULL
)

-- 3️⃣ Output all labs
SELECT *
FROM labs
ORDER BY hadm_id, charttime;

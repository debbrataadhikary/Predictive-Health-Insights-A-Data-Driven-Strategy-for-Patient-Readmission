CREATE OR REPLACE TABLE `circular-hybrid-482408-e9.hospital_data.cleaned_hospital_data` AS
SELECT 
    -- 1. Unique ID Generation (Phase 1)
    ROW_NUMBER() OVER () AS encounter_id, 
    
    -- 2. Basic Hospital Statistics
    time_in_hospital, 
    num_lab_procedures, 
    num_medications, 
    number_diagnoses, 
    (number_outpatient + number_inpatient + number_emergency) AS total_prior_visits, 

    -- 3. Demographic Information (Gender, Race, Age)
    CASE 
        WHEN `gender_Female` IS TRUE THEN 'Female'
        ELSE 'Male' 
    END AS gender, 

    CASE 
        WHEN race_AfricanAmerican IS TRUE THEN 'African American'
        WHEN race_Caucasian IS TRUE THEN 'Caucasian'
        ELSE 'Other'
    END AS race, 

    CASE 
        WHEN age_40_50 IS TRUE THEN '40-50'
        WHEN age_50_60 IS TRUE THEN '50-60'
        WHEN age_60_70 IS TRUE THEN '60-70'
        WHEN age_70_80 IS TRUE THEN '70-80'
        WHEN age_80_90 IS TRUE THEN '80-90'
        ELSE 'Other'
    END AS age_group, 

    -- 4. Re-Admission Status  (KPI)
    CASE 
        WHEN readmitted = 0 THEN 'No'
        ELSE 'Yes'
    END AS is_readmitted, 

    -- 5. Visit Grouping (Operational Efficiency)
  CASE 
    WHEN (number_outpatient + number_inpatient + number_emergency) = 0 THEN '1. 0 Visits'
    WHEN (number_outpatient + number_inpatient + number_emergency) BETWEEN 1 AND 5 THEN '2. 1-5 Visits'
    WHEN (number_outpatient + number_inpatient + number_emergency) BETWEEN 6 AND 10 THEN '3. 6-10 Visits'
    WHEN (number_outpatient + number_inpatient + number_emergency) BETWEEN 11 AND 20 THEN '4. 11-20 Visits'
    ELSE '5. 20+ Visits' 
END AS visit_group,

    -- 6. Medication Impact Analysis (Insulin & Metformin)
    CASE WHEN insulin_No IS FALSE THEN 'Yes' ELSE 'No' END AS taking_insulin,
    CASE WHEN metformin_No IS FALSE THEN 'Yes' ELSE 'No' END AS taking_metformin,

    -- 7. Patient Complexity Index (PCI - Custom Metric)
    (num_medications + num_lab_procedures + number_diagnoses) AS patient_complexity_index,

    -- 8. Patient Segmentation (Chronic, Acute, Routine)
    CASE 
        WHEN (number_outpatient + number_inpatient + number_emergency) >= 5 THEN 'Chronic'
        WHEN time_in_hospital > 7 OR number_diagnoses > 10 THEN 'Acute'
        ELSE 'Routine'
    END AS patient_segment,

    -- 9. Diagonois Mapping (Disease Name Indicated by Number)
    CASE 
        WHEN number_diagnoses >= 13 THEN 'Multiple Chronic Conditions'
        WHEN number_diagnoses BETWEEN 9 AND 12 THEN 'Diabetes & Metabolic Risk'
        WHEN number_diagnoses BETWEEN 5 AND 8 THEN 'Cardiovascular/Respiratory'
        ELSE 'General Medical'
    END AS diagnosis_name,

    -- 10. Diagonosis Severity Level
    CASE 
        WHEN number_diagnoses <= 4 THEN 'Low Complexity'
        WHEN number_diagnoses BETWEEN 5 AND 8 THEN 'Moderate'
        WHEN number_diagnoses BETWEEN 9 AND 12 THEN 'High Complexity'
        ELSE 'Critical'
    END AS diagnosis_severity,

   -- 11. Final Risk Category (Executive Summary Insights)
    CASE 
        WHEN (num_medications + num_lab_procedures + number_diagnoses) > 100 THEN 'High Risk'
        WHEN (num_medications + num_lab_procedures + number_diagnoses) BETWEEN 60 AND 100 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category,

    -- 12. Predictive Readmission Probability Score 
    ROUND(
      (
        CASE 
          WHEN (num_medications + num_lab_procedures + number_diagnoses) > 100 THEN 30
          WHEN (num_medications + num_lab_procedures + number_diagnoses) BETWEEN 60 AND 100 THEN 20
          ELSE 10 
        END +
        CASE 
          WHEN (number_outpatient + number_inpatient + number_emergency) >= 5 THEN 40
          WHEN (number_outpatient + number_inpatient + number_emergency) BETWEEN 1 AND 4 THEN 20
          ELSE 0 
        END +
        CASE WHEN (age_70_80 IS TRUE OR age_80_90 IS TRUE) THEN 15 ELSE 0 END +
        CASE WHEN insulin_No IS FALSE THEN 15 ELSE 0 END
      ), 2
    ) AS readmission_probability_score

FROM `circular-hybrid-482408-e9.hospital_data.raw_hospital_data`;
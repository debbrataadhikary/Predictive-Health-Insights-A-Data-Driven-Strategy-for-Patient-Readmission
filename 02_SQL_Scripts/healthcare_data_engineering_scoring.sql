CREATE OR REPLACE TABLE `circular-hybrid-482408-e9.hospital_data.cleaned_hospital_data` AS

WITH patient_base AS (
    -- PHASE 1: Data Normalization & Basic Calculations
    SELECT 
        ROW_NUMBER() OVER () AS encounter_id,
        time_in_hospital,
        num_lab_procedures,
        num_medications,
        number_diagnoses,
        (number_outpatient + number_inpatient + number_emergency) AS total_prior_visits,
        
        -- Demographic Mapping
        CASE WHEN `gender_Female` IS TRUE THEN 'Female' ELSE 'Male' END AS gender,
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

        -- KPIs & Clinical Status
        CASE WHEN readmitted = 0 THEN 'No' ELSE 'Yes' END AS is_readmitted,
        CASE WHEN insulin_No IS FALSE THEN 'Yes' ELSE 'No' END AS taking_insulin,
        CASE WHEN metformin_No IS FALSE THEN 'Yes' ELSE 'No' END AS taking_metformin,
        
        -- Complexity Component
        (num_medications + num_lab_procedures + number_diagnoses) AS patient_complexity_index,
        
        -- Scoring Helper (Flag for high-risk age)
        (age_70_80 IS TRUE OR age_80_90 IS TRUE) AS is_high_risk_age
    FROM `circular-hybrid-482408-e9.hospital_data.raw_hospital_data`
),

risk_calculation_layer AS (
    -- PHASE 2: Single-source Logic for Risk Scores
    SELECT 
        *,
        (
            CASE 
                WHEN patient_complexity_index > 100 THEN 30
                WHEN patient_complexity_index BETWEEN 60 AND 100 THEN 20
                ELSE 10 
            END +
            CASE 
                WHEN total_prior_visits >= 5 THEN 40
                WHEN total_prior_visits BETWEEN 1 AND 4 THEN 20
                ELSE 0 
            END +
            CASE WHEN is_high_risk_age IS TRUE THEN 15 ELSE 0 END +
            CASE WHEN taking_insulin = 'Yes' THEN 15 ELSE 0 END
        ) AS calculated_risk_score
    FROM patient_base
)

-- PHASE 3: Final Output 
SELECT 
    * EXCEPT(calculated_risk_score, is_high_risk_age),
    
    -- Visit Grouping (Matches Original Logic)
    CASE 
        WHEN total_prior_visits = 0 THEN '1. 0 Visits'
        WHEN total_prior_visits BETWEEN 1 AND 5 THEN '2. 1-5 Visits'
        WHEN total_prior_visits BETWEEN 6 AND 10 THEN '3. 6-10 Visits'
        WHEN total_prior_visits BETWEEN 11 AND 20 THEN '4. 11-20 Visits'
        ELSE '5. 20+ Visits' 
    END AS visit_group,

    -- Patient Segmentation
    CASE 
        WHEN total_prior_visits >= 5 THEN 'Chronic'
        WHEN time_in_hospital > 7 OR number_diagnoses > 10 THEN 'Acute'
        ELSE 'Routine'
    END AS patient_segment,

    -- Diagnosis Intelligence
    CASE 
        WHEN number_diagnoses >= 13 THEN 'Multiple Chronic Conditions'
        WHEN number_diagnoses BETWEEN 9 AND 12 THEN 'Diabetes & Metabolic Risk'
        WHEN number_diagnoses BETWEEN 5 AND 8 THEN 'Cardiovascular/Respiratory'
        ELSE 'General Medical'
    END AS diagnosis_name,

    -- Severity Categorization
    CASE 
        WHEN number_diagnoses <= 4 THEN 'Low Complexity'
        WHEN number_diagnoses BETWEEN 5 AND 8 THEN 'Moderate'
        WHEN number_diagnoses BETWEEN 9 AND 12 THEN 'High Complexity'
        ELSE 'Critical'
    END AS diagnosis_severity,

    -- Key Decision Metrics (Final Mapping to Power BI)
    ROUND(calculated_risk_score, 2) AS readmission_probability_score,
    
    CASE 
        WHEN calculated_risk_score >= 75 THEN '1. Critical High Risk'
        WHEN calculated_risk_score BETWEEN 40 AND 74 THEN '2. Moderate Risk'
        ELSE '3. Low Risk'
    END AS risk_category

FROM risk_calculation_layer;

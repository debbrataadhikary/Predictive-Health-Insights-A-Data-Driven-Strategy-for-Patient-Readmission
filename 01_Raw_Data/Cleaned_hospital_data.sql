CREATE TABLE cleaned_hospital_data AS
SELECT 
    ROW_NUMBER() OVER () AS encounter_id,
    time_in_hospital,
    num_lab_procedures,
    num_procedures,
    num_medications,
    number_diagnoses,
    (number_outpatient + number_emergency + number_inpatient) AS total_prior_visits,
    CASE 
        WHEN "race_Caucasian" = True THEN 'Caucasian'
        WHEN "race_AfricanAmerican" = True THEN 'African American'
        ELSE 'Other/Unknown'
    END AS race,
    CASE WHEN "gender_Female" = True THEN 'Female' ELSE 'Male' END AS gender,
    CASE 
        WHEN "age_[40-50)" = True THEN '40-50'
        WHEN "age_[50-60)" = True THEN '50-60'
        WHEN "age_[60-70)" = True THEN '60-70'
        WHEN "age_[70-80)" = True THEN '70-80'
        WHEN "age_[80-90)" = True THEN '80-90'
        ELSE 'Other'
    END AS age_group,
    CASE 
        WHEN "medical_specialty_InternalMedicine" = True THEN 'Internal Medicine'
        WHEN "medical_specialty_Cardiology" = True THEN 'Cardiology'
        WHEN "medical_specialty_Emergency/Trauma" = True THEN 'Emergency/Trauma'
        WHEN "medical_specialty_Family/GeneralPractice" = True THEN 'Family Practice'
        ELSE 'Other/Unknown'
    END AS specialty,
    CASE WHEN "insulin_No" = False THEN 'Yes' ELSE 'No' END AS insulin_prescribed,
    CASE WHEN readmitted = 1 THEN 'Yes' ELSE 'No' END AS is_readmitted
FROM raw_hospital_data;

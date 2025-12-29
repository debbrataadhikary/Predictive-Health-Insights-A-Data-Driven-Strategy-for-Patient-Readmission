# Predictive Health Insights: A Data-Driven Strategy for Patient Readmission

## 🏥 Project Overview
This project focuses on identifying and predicting hospital readmission risks for diabetic patients. By integrating **BigQuery SQL** for advanced data engineering and **Power BI** for AI-driven predictive analytics, this solution provides hospital leadership with a strategic roadmap to reduce 30-day readmission rates and optimize clinical resources.

---

## 📊 Executive Summary
The primary objective is to move from historical reporting to **Prescriptive Analytics**. Our dashboard analyzes 25,000 patient encounters to identify high-risk cohorts and simulate the impact of clinical interventions.

![Executive Summary](./Images/1.%20Executive_Summary.png)

### Key Performance Indicators (KPIs):
* **Overall Readmission Rate:** 45.64%
* **Average Length of Stay:** 4.4 Days
* **Patient Complexity Index (PCI):** Calculated based on medications, lab procedures, and diagnoses.

---

## 🔍 Predictive Insights & AI Findings
Using Power BI's **Key Influencers AI**, we identified critical drivers that significantly increase the likelihood of readmission.

![Probability Analysis](./Images/8.%20Probability_analysis.png)

* **Prior Hospital Visits:** Patients with more than 8 prior visits are **1.75x more likely** to be readmitted.
* **Patient Segment:** The 'Chronic' segment exhibits the highest risk, with a readmission rate of **71.75%**.
* **Complexity Impact:** A high correlation exists between patients with 16+ medications and increased readmission risk.

---

## 🛠️ Technical Workflow & Methodology

### 1. Data Engineering (SQL)
Cleaned and transformed raw medical data using Google BigQuery. We implemented a **Weighted Risk Scoring Model** based on:
* **Prior Utilization (40%)**
* **Medical Complexity (30%)**
* **Clinical Profile (30%)**

### 2. Strategic Simulation (What-If Analysis)
The dashboard includes a simulation tool to set improvement targets.
* **Goal Setting:** Achieving a 20% improvement in discharge efficiency can reduce the simulated readmission rate to **36.40%**.

![Deep Dive Analysis](./Images/4.%20Deep-Dive.png)

---

## 📋 Strategic Recommendations
1. **High-Risk Alerts:** Implement automated alerts for patients with a Risk Score >80.
2. **Targeted Chronic Care:** Assign dedicated case managers for the 'Chronic' patient segment.
3. **Medication Counseling:** Focused pharmacist review for patients in the high polypharmacy group.

---

## 📁 Folder Structure
* **01_Raw_Data:** Contains the anonymized dataset.
* **02_SQL_Scripts:** SQL queries for data cleaning and feature engineering.
* **03_PowerBI_Dashboard:** The `.pbix` file for the interactive dashboard.
* **04_Final_Report:** Detailed executive report for hospital leadership.
* **Images:** All visuals and screenshots used in this documentation.

---

## 🚀 How to Use
1. Run the scripts in `02_SQL_Scripts` on your SQL environment.
2. Open the `03_PowerBI_Dashboard` file to explore interactive insights.
3. Refer to the `04_Final_Report` for a full business breakdown.
---

## ⚠️ Assumptions & Limitations
* **Data Scope:** This analysis is based on anonymized administrative health records and does not include clinical outcomes beyond readmission.
* **Decision Support:** Risk scores are probabilistic and intended for decision support, not as a direct clinical diagnosis.
* **Simulation Variance:** Simulation outcomes assume linear intervention effects and may vary based on real-world staffing and implementation.

**Author:** [Debbrata Kumar Adhikary]  
**Tools Used:** SQL (BigQuery), Power BI (DAX, AI Visuals), Data Storytelling.

# 📊 E-Commerce Customer Churn Prediction (Time-Based, Leakage-Free)

## 📖 Overview

This project builds a **production-style, time-based customer churn
prediction model** using MySQL and Scikit-learn.

The pipeline prevents **temporal data leakage** by dynamically defining
a cutoff date and separating feature and prediction windows.

The final model achieves **\~0.97 ROC-AUC** on a holdout set using
behavioral features.

------------------------------------------------------------------------

## 🎯 Business Problem

Can we predict which customers will churn (stop purchasing) in the next
60 days using historical behavioral data?

The objective is to:

-   Identify high-risk customers\
-   Enable proactive retention campaigns\
-   Maximize Customer Lifetime Value (CLV)

------------------------------------------------------------------------

## 🧠 Methodology

### 1️⃣ Time-Based Modeling Framework

Instead of using the entire dataset at once (which causes leakage), we
designed a proper time-based split:

  -----------------------------------------------------------------------
  Stage                      Description
  -------------------------- --------------------------------------------
  Feature Window             Orders before dynamic cutoff
                             (MAX(order_date) - 180 days)

  Prediction Window          60 days after cutoff

  Label                      Churn = 1 if no purchase in prediction
                             window
  -----------------------------------------------------------------------

This ensures: - No future information leaks into training - Realistic
business simulation - Production-ready modeling logic

------------------------------------------------------------------------

### 2️⃣ Feature Engineering (SQL)

Features engineered using SQL views:

-   **Recency** → Days since last purchase before cutoff\
-   **Frequency** → Total orders before cutoff\
-   **Monetary** → Total spend before cutoff\
-   **Average Order Value (AOV)**

All feature engineering logic is modularized inside the `sql/`
directory.

------------------------------------------------------------------------

### 3️⃣ Machine Learning Models

Models trained using Scikit-learn:

-   Logistic Regression (class-balanced)
-   Random Forest
-   Gradient Boosting

Evaluation Metrics: - ROC-AUC - Precision / Recall - Classification
Report

------------------------------------------------------------------------

## 📊 Results

  Model                 ROC-AUC
  --------------------- ---------
  Logistic Regression   \~0.97
  Random Forest         \~0.97
  Gradient Boosting     \~0.97

The model demonstrates strong predictive performance while maintaining a
leakage-free design.

------------------------------------------------------------------------

## 🏗️ Project Structure

    Ecommerce-Churn-Prediction/
    │
    ├── data/
    │   └── processed/
    │
    ├── sql/
    │   ├── 01_create_tables.sql
    │   ├── 02_load_data.sql
    │   ├── 03_feature_engineering.sql
    │   ├── 04_churn_label.sql
    │   └── 05_final_dataset.sql
    │
    ├── notebooks/
    │   └── 01_eda.ipynb
    │
    ├── output/
    │   └── churn_scores.csv
    │
    ├── p.py
    └── README.md

------------------------------------------------------------------------

## 🚀 How to Run the Project

### Step 1: Create Database & Load Data

Execute SQL scripts in order:

1.  `01_create_tables.sql`
2.  `02_load_data.sql`
3.  `03_feature_engineering.sql`
4.  `04_churn_label.sql`
5.  `05_final_dataset.sql`

### Step 2: Export Final Dataset

Run:

    SELECT * FROM final_customer_features;

Export as:

    data/processed/customer_features.csv

### Step 3: Train Model

    python p.py

Churn probabilities will be saved in:

    output/churn_scores.csv

------------------------------------------------------------------------

## 🔍 Key Challenges Solved

-   Prevented temporal leakage using dynamic cutoff logic
-   Handled imbalanced dataset using class-weighted models
-   Built reproducible SQL feature engineering pipeline
-   Structured project for production-style implementation

------------------------------------------------------------------------

## 📈 Business Impact

This model enables:

-   Identification of high-risk customers
-   Targeted retention campaigns
-   Marketing budget optimization
-   Improved customer lifetime value

------------------------------------------------------------------------

## 🧩 Future Improvements

-   SHAP feature importance
-   Threshold optimization
-   Lift and decile analysis
-   Model deployment via API
-   Real-time scoring pipeline

------------------------------------------------------------------------

## 🏆 Key Takeaways

-   Importance of time-based modeling in churn prediction
-   Avoiding data leakage in ML pipelines
-   Structuring reproducible SQL + ML workflows
-   Aligning ML outputs with business objectives

------------------------------------------------------------------------

## 👤 Author

Built as an end-to-end churn prediction pipeline integrating SQL-based
feature engineering with machine learning modeling.

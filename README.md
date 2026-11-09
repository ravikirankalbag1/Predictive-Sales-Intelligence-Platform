# Predictive Sales Intelligence Platform

An end-to-end Machine Learning project designed to forecast monthly product-level revenue, identify key sales drivers, and support data-driven business decisions through predictive analytics and interactive reporting.

## 1. Project Overview

The **Predictive Sales Intelligence Platform** is developed for a fictional retail organization, ABC Retail Corporation, operating across 7 stores in India.

The platform leverages historical retail transaction data to predict next-month revenue at the Product-Year-Month level. It combines data engineering, exploratory data analysis, feature engineering, machine learning, model evaluation, experiment tracking, and application development.

The primary objective is to help business stakeholders anticipate revenue trends, understand factors influencing sales performance, and make informed operational and strategic decisions.

## 2. Business Problem

Retail businesses often rely on historical sales reports to understand performance. However, historical reporting alone does not provide sufficient visibility into future revenue expectations.

This project addresses the following business challenges:

- Predicting monthly revenue at an individual product level.
- Identifying key factors influencing revenue generation.
- Understanding product-level sales patterns and trends.
- Supporting data-driven inventory and business planning.
- Providing accessible insights through dashboards and predictive interfaces.

## 3. Project Objectives

- Build a reliable monthly revenue forecasting model.
- Perform exploratory data analysis and statistical analysis.
- Engineer meaningful temporal, product, customer, and store-related features.
- Evaluate multiple machine learning algorithms.
- Interpret model predictions using feature importance and SHAP.
- Track experiments and model artifacts using MLflow.
- Develop an API and interactive application for model consumption.
- Present historical sales insights through Power BI.

## 4. Dataset Overview

The project uses a retail transaction dataset representing ABC Retail Corporation's business operations between 2021 and 2025.

| Dataset component | Records |
|---|---:|
| Customers | 10,000 |
| Stores | 7 |
| Products | 1,820 |
| Sales transactions | 700,000 |

**Prediction target:** `next_monthly_revenue`

**Prediction granularity:** Product + Year + Month

The dataset includes information relating to customers, products, stores, sales transactions, and time-based attributes.

## 5. Technology Stack

| Category | Technologies |
|---|---|
| Programming | Python |
| Database | PostgreSQL |
| Data Analysis | Pandas, NumPy |
| Visualization | Matplotlib, Seaborn, Power BI |
| Machine Learning | Scikit-learn, LightGBM |
| Model Explainability | SHAP |
| Experiment Tracking | MLflow |
| API Development | FastAPI |
| Application Development | Streamlit |
| Development Environment | Jupyter Notebook, VS Code |
| Version Control | Git, GitHub |

## 6. Project Workflow

### Phase 1: Data Engineering and Database Management
- Designed and populated a relational PostgreSQL database.
- Created structured tables for customers, stores, products, and sales transactions.
- Performed SQL-based exploratory analysis.
- Prepared data for downstream analytical workflows.

### Phase 2: Exploratory Data Analysis
- Analyzed historical revenue patterns.
- Examined product-wise and store-wise sales performance.
- Investigated temporal trends and seasonality.
- Identified data quality issues and potential feature relationships.

### Phase 3: Data Preprocessing and Feature Engineering
- Handled missing values and performed data cleaning.
- Created temporal and business-related features.
- Prepared the modelling dataset.
- Applied feature selection using RFECV.
- Used a time-based validation strategy to avoid temporal leakage.

### Phase 4: Model Development and Evaluation
- Developed and evaluated multiple regression models.
- Implemented Random Forest and LightGBM models.
- Performed hyperparameter tuning.
- Evaluated models using MAE, RMSE, and R².
- Selected the final modelling approach based on validation performance and evaluated it on the held-out test period.

### Phase 5: Model Explainability
- Used SHAP with TreeExplainer to interpret model predictions.
- Analyzed feature contributions.
- Identified influential factors affecting predicted revenue.

### Phase 6: Experiment Tracking and Model Management
- Integrated MLflow for experiment tracking.
- Logged model parameters and evaluation metrics.
- Tracked trained model artifacts and preprocessing objects.
- Registered experiment runs for reproducibility and comparison.

### Phase 7: Application and Deployment
- Developing a FastAPI-based prediction interface.
- Planning an interactive Streamlit application for revenue predictions.
- Integrating historical sales insights through Power BI.
- Performing end-to-end application validation.

## 7. Model Evaluation

A chronological data split was implemented to reflect real-world forecasting conditions.

| Dataset | Period | Purpose |
|---|---|---|
| Training | 2021–2023 | Model training |
| Validation | 2024 | Model selection and tuning |
| Testing | 2025 | Final model evaluation |

**Final Random Forest evaluation on the held-out 2025 test dataset:**

| Evaluation Metric | Result |
|---|---:|
| MAE | 18,372.64 |
| RMSE | 54,774.25 |
| R² Score | 0.8122 |

The model achieved an R² score of approximately 81.22% on the unseen 2025 test period.

MAE and RMSE provide complementary measures of prediction error, while R² indicates how much of the variation in the target variable is explained by the model.

## 8. Model Explainability

Model interpretability is an important component of the platform.

SHAP (SHapley Additive exPlanations) is used to understand the contribution of individual features to model predictions.

This helps answer questions such as:

- Which features have the greatest influence on revenue predictions?
- How do different features contribute to individual predictions?
- Are the model's predictions driven by meaningful business patterns?

## 9. Experiment Tracking with MLflow

MLflow is integrated to maintain a structured record of machine learning experiments.

The tracked information includes:

- Model parameters.
- Evaluation metrics.
- Trained model artifacts.
- Preprocessing artifacts.
- Experiment runs for model comparison.

## 10. Repository Structure

The repository is organized into separate components for data management, analysis, modelling, application development, and documentation.

- `data/` – Dataset and processed data.
- `notebooks/` – Exploratory analysis, feature engineering, and model development.
- `sql/` – Database queries and SQL-based analysis.
- `src/` – Reusable Python source code.
- `models/` – Model-related files and artifacts.
- `app/` – Application components.
- `docs/` – Project documentation and supporting visuals.

## 11. Key Outcomes

- Developed a complete analytical workflow using PostgreSQL and Python.
- Implemented a chronological train-validation-test strategy.
- Built machine learning models for product-level monthly revenue forecasting.
- Achieved an R² score of approximately 0.81 on the unseen test dataset.
- Incorporated SHAP for model interpretability.
- Implemented MLflow for experiment tracking and model artifact management.
- Established the foundation for API-based prediction and interactive business intelligence applications.

## 12. Future Enhancements

- Complete API-based model serving.
- Develop and integrate the Streamlit prediction interface.
- Enhance forecasting performance through additional modelling experiments.
- Integrate predictive outputs with interactive business dashboards.
- Explore automated model monitoring and periodic retraining.

## 13. Author

**Ravikiran Kalbag**

- LinkedIn: https://www.linkedin.com/in/ravikiran-kalbag-11715b148/
- GitHub: https://github.com/ravikirankalbag1

---

*This project is developed as an end-to-end portfolio project to demonstrate practical skills in data engineering, statistical analysis, machine learning, model explainability, experiment tracking, and business intelligence.*

# 🏭 Karawang Air Hazard Prediction Pipeline

![Data Engineering](https://img.shields.io/badge/Data%20Engineering-Zoomcamp-blue)
![Google Cloud](https://img.shields.io/badge/GCP-Cloud-orange)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-green)

## 📖 1. Problem Statement

Karawang, located in West Java, Indonesia, is recognized as one of the largest industrial estates in Southeast Asia, housing thousands of manufacturing plants ranging from automotive to heavy industries. Compounding this industrial density is Karawang's geographical location near the northern coast of Java. The combination of massive industrial emissions and coastal sea breezes frequently traps particulate matter inland, leading to volatile and often hazardous air quality conditions.

Currently, local residents and health monitoring agencies lack an integrated, predictive system to anticipate these hazardous air conditions. This project solves this problem by building an end-to-end data pipeline that ingests real-time weather and air quality data (via Open-Meteo API), processes it in the cloud, and utilizes a Machine Learning model (Logistic Regression via BigQuery ML) to predict the probability of hazardous air conditions. This provides actionable insights through a dashboard, allowing stakeholders to monitor historical trends and simulate future hazard scenarios.

---

## 🏗️ 2. Data Pipeline Architecture

This project implements a fully automated, cloud-native **batch processing** pipeline structured around the Medallion Architecture (Bronze, Silver, Gold).

1. **Infrastructure as Code (IaC):** All cloud resources on Google Cloud Platform (GCP) are provisioned programmatically using **Terraform**, ensuring a reproducible infrastructure.
2. **End-to-End Orchestration & Ingestion:** The workflow is orchestrated using **Bruin**, a modern Rust-based data asset manager. Bruin triggers Python scripts to extract data from the Open-Meteo API and load it securely into a Google Cloud Storage (GCS) Data Lake in `.parquet` format.
3. **Data Warehouse (Zero-Copy Integration):** BigQuery reads the Data Lake files directly using `EXTERNAL TABLE` definitions (Silver Layer), eliminating unnecessary data duplication.
4. **Transformations:** Data cleaning, type coercion, and feature engineering (creating the `is_hazardous` label) are executed via pure SQL transformations managed by Bruin. 
5. **Warehouse Optimization:** To optimize for upstream queries and ML training, the final analytical tables in BigQuery are explicitly **partitioned** by `observation_time` (daily) to minimize scan costs for time-series data, and **clustered** by `is_hazardous` to speed up filtering operations.
6. **Machine Learning:** A Logistic Regression model is trained directly within the Data Warehouse using BigQuery ML to predict hazard probabilities.
7. **Visualization:** The pipeline culminates in a Looker Studio dashboard:
<img width="987" height="676" alt="image" src="https://github.com/user-attachments/assets/82077256-0d43-497d-b08e-3c8d53e353e9" />

---

## 🛠️ 3. Technologies Used

* **Cloud Provider:** Google Cloud Platform (GCS, BigQuery)
* **Infrastructure as Code (IaC):** Terraform
* **Workflow Orchestration & Transformation:** Bruin CLI
* **Programming Languages:** Python 3.10 & Standard SQL
* **Machine Learning:** BigQuery ML (Logistic Regression)
* **Data Visualization:** Looker Studio
* **CI/CD:** GitHub Actions (Automated daily runs)

---

## 🚀 4. Reproducibility (How to Run the Code)

Follow these instructions to reproduce the project from a clean clone.

### Prerequisites
1.  A Google Cloud Platform account with an active Project.
2.  A Service Account with `Storage Admin` and `BigQuery Admin` roles. Download the JSON key.
3.  Install [Terraform](https://developer.hashicorp.com/terraform/install).
4.  Install [Bruin CLI](https://bruin.dev/docs/getting-started/installation).

### Step 1: Clone and Setup Environment
```bash
git clone [https://github.com/yourusername/karawang-air-hazard-pipeline.git](https://github.com/yourusername/karawang-air-hazard-pipeline.git)
cd karawang-air-hazard-pipeline

# Copy the example environment file and fill in your variables
cp .env.example .env
```

### Step 2: Provision Infrastructure (Terraform)
Navigate to the terraform directory to create the GCS Bucket and BigQuery Dataset.

```bash
cd terraform
terraform init
terraform plan -var="project=YOUR_GCP_PROJECT_ID"
terraform apply -var="project=YOUR_GCP_PROJECT_ID"
cd ..
```

### Step 3: Run the Data Pipeline (Bruin)
Bruin handles the Python dependency management automatically in isolated environments. Run the pipeline to extract data, load to GCS, run SQL transformations, and train the ML model.
```bash
bruin run --start-date ... --end-date ...
```

🌟 5. Going the Extra Mile (Advanced Features)
To make this project production-ready, the following optional features were implemented:
CI/CD Pipeline (GitHub Actions): A .github/workflows/daily_pipeline.yml automates the ingestion. It provisions an ephemeral Ubuntu runner daily, authenticates with GCP, installs Bruin, dynamically passes the current date to the API, and updates the Data Warehouse without human intervention.
API Error Handling: Try-except blocks are implemented to handle Open-Meteo API rate limits and timeouts, preventing pipeline crashes during extraction.

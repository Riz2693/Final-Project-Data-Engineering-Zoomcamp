# 🏭 Karawang Air Hazard Prediction Pipeline

![Data Engineering](https://img.shields.io/badge/Data%20Engineering-Zoomcamp-blue)
![Google Cloud](https://img.shields.io/badge/GCP-Cloud-orange)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-green)

## 📖 1. Problem Statement

Karawang, located in West Java, Indonesia, is recognized as one of the largest industrial estates in Southeast Asia. The combination of massive industrial emissions and coastal sea breezes frequently traps particulate matter inland, leading to volatile air quality conditions.

Currently, there is a lack of an integrated system to anticipate these conditions. This project builds an end-to-end data pipeline that ingests daily weather and air quality data (via Open-Meteo API), processes it in the cloud, and utilizes a Machine Learning model (Logistic Regression via BigQuery ML) to predict the probability of hazardous air conditions. This provides actionable insights through a dashboard, allowing users to monitor historical trends and simulate future hazard scenarios.

---

## 🏗️ 2. Data Pipeline Architecture

This project implements a cloud-native **batch processing** pipeline.

1. **Infrastructure as Code (IaC):** Cloud resources on Google Cloud Platform (GCP) are provisioned using **Terraform**.
2. **Orchestration & Ingestion:** The workflow is orchestrated using **Bruin**. Python scripts are triggered to extract data from the Open-Meteo API and load it into a Google Cloud Storage (GCS) Data Lake in `.parquet` format.
3. **Data Warehouse (External Tables):** BigQuery reads the Data Lake files directly using `EXTERNAL TABLE` definitions (Silver Layer).
4. **Transformations:** Data cleaning, type coercion (handling timestamp floats), and feature engineering are executed via pure SQL transformations managed by Bruin. 
5. **Warehouse Optimization:** The final analytical table in BigQuery is explicitly **partitioned** by `DATE(observation_time)` to minimize query costs and **clustered** by `is_hazardous` to optimize sorting operations.
6. **Machine Learning:** A Logistic Regression model is trained within BigQuery ML to predict hazard probabilities.
7. **Visualization:** A Looker Studio dashboard consisting of **two distinct tiles**:
<img width="987" height="676" alt="image" src="https://github.com/user-attachments/assets/82077256-0d43-497d-b08e-3c8d53e353e9" />

---

## 🛠️ 3. Technologies Used

* **Cloud Provider:** Google Cloud Platform (GCS, BigQuery)
* **Infrastructure as Code:** Terraform
* **Workflow Orchestration:** Bruin CLI
* **Programming Languages:** Python 3.10 & Standard SQL
* **Machine Learning:** BigQuery ML (Logistic Regression)
* **Data Visualization:** Looker Studio
* **CI/CD Orchestration:** GitHub Actions

---

## 🚀 4. Reproducibility (How to Run the Code)

### Prerequisites
1.  A Google Cloud Platform account with an active Project.
2.  A Service Account with `Storage Admin` and `BigQuery Admin` roles. Download the JSON key.
3.  Install [Terraform](https://developer.hashicorp.com/terraform/install).
4.  Install [Bruin CLI](https://bruin.dev/docs/getting-started/installation).

### Step 1: Clone and Setup Environment
```bash
git clone [https://github.com/yourusername/karawang-air-hazard-pipeline.git](https://github.com/yourusername/karawang-air-hazard-pipeline.git)
cd karawang-air-hazard-pipeline

# Configure your GCP credentials
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service_account.json"
```

### Step 2: Provision Infrastructure (Terraform)
Navigate to the terraform directory to create the GCS Bucket and BigQuery Dataset.

```bash
cd terraform
terraform init
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
CI/CD Pipeline (GitHub Actions): A .github/workflows/daily_pipeline.yml automates the pipeline. It provisions an Ubuntu runner daily, authenticates with GCP via Secrets, installs Bruin, and updates the Data Warehouse without manual intervention.

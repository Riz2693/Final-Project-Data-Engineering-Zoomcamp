terraform {
  # Memberi tahu Terraform bahwa kita butuh plugin khusus untuk meremote Google Cloud.
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Konfigurasi proyek Google Cloud mana yang mau kita bangun.
provider "google" {
  project = "final-project-zoomcamp-493910"
  region  = "asia-southeast2" # Lokasi server ditaruh di Jakarta (agar latensi cepat).
}

# Membuat Google Cloud Storage (GCS)
# Ibarat membuat "Google Drive" khusus untuk menampung file data mentah berukuran raksasa.
resource "google_storage_bucket" "env_raw_data" {
  name          = "env-raw-data" # Nama folder awan ini harus unik di seluruh dunia
  location      = "asia-southeast2"
  # Mengizinkan kita untuk menghapus folder ini beserta seluruh isinya kelak (untuk hemat biaya).
  force_destroy = true
}

# Membuat Dataset di Google BigQuery
# Ibarat membuat "Database Server" khusus untuk menyimpan tabel-tabel data yang terstruktur.
resource "google_bigquery_dataset" "env_dataset" {
  dataset_id = "env_feature_store" # Nama database kamu
  location   = "asia-southeast2"
}
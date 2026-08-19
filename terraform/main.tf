terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ---------------------------------------------------------
# KMS
# ---------------------------------------------------------

resource "google_kms_key_ring" "habotconnect" {
  name     = "habotconnect-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "raw_landing" {
  name            = "d0-raw-landing-key"
  key_ring        = google_kms_key_ring.habotconnect.id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}

# ---------------------------------------------------------
# D0 - Raw Landing GCS Bucket
# ---------------------------------------------------------

resource "google_storage_bucket" "d0_raw_landing" {
  name     = var.bucket_name
  location = var.region

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.raw_landing.id
  }

  lifecycle_rule {
    condition {
      age = 30
    }

    action {
      type = "Delete"
    }
  }
}

# ---------------------------------------------------------
# D1 - Staged / Enforced BigQuery Dataset
# ---------------------------------------------------------

resource "google_bigquery_dataset" "d1_staged_enforced" {
  dataset_id = var.dataset_id
  location   = var.region

  delete_contents_on_destroy = false

  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key.raw_landing.id
  }
}

# ---------------------------------------------------------
# BigQuery Table
# ---------------------------------------------------------

resource "google_bigquery_table" "student_onboarding" {
  dataset_id = google_bigquery_dataset.d1_staged_enforced.dataset_id
  table_id   = "student_onboarding"

  deletion_protection = false

  schema = jsonencode([
    {
      name = "student_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "student_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "learning_support_required"
      type = "BOOL"
      mode = "REQUIRED"
    },
    {
      name = "region"
      type = "STRING"
      mode = "REQUIRED"
    }
  ])
}

# ---------------------------------------------------------
# Row Level Security
# ---------------------------------------------------------

resource "google_bigquery_row_access_policy" "student_region_policy" {
  project        = var.project_id
  dataset_id     = google_bigquery_dataset.d1_staged_enforced.dataset_id
  table_id       = google_bigquery_table.student_onboarding.table_id
  policy_id      = "region-filter"
  filter_predicate = "region = 'UK'"

  grantees = [
  "group:${var.analytics_group}"
]
}

# ---------------------------------------------------------
# GCS IAM - Conditional Access
# ---------------------------------------------------------

resource "google_storage_bucket_iam_member" "raw_landing_viewer" {
  bucket = google_storage_bucket.d0_raw_landing.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.runtime_service_account}"

  condition {
    title       = "TemporaryReadAccess"
    description = "Read access expires after the approved date"
    expression  = "request.time < timestamp('2030-01-01T00:00:00Z')"
  }
}

# ---------------------------------------------------------
# BigQuery IAM
# ---------------------------------------------------------

resource "google_bigquery_dataset_iam_member" "analytics_viewer" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.d1_staged_enforced.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "group:${var.analytics_group}"
}
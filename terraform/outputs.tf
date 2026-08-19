output "raw_landing_bucket" {
  description = "D0 Raw Landing GCS bucket"
  value       = google_storage_bucket.d0_raw_landing.name
}

output "staged_dataset" {
  description = "D1 Staged/Enforced BigQuery dataset"
  value       = google_bigquery_dataset.d1_staged_enforced.dataset_id
}

output "student_onboarding_table" {
  description = "Student onboarding BigQuery table"
  value       = google_bigquery_table.student_onboarding.table_id
}
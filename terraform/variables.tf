variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Globally unique GCS bucket name"
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
  default     = "d1_staged_enforced"
}

variable "runtime_service_account" {
  description = "Service account used by the application runtime"
  type        = string
}

variable "analytics_group" {
  description = "Google Group allowed to access filtered analytics rows"
  type        = string
}
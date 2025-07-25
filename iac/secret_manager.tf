data "google_secret_manager_secret_version" "db_password_version" {
  secret  = "sterling-db-temp-password"
  project = var.project_id
}
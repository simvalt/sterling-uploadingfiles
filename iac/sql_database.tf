resource "google_sql_database_instance" "mysql_instance_sterling" {
  name             = local.sterling_database_name
  region           = var.region
  database_version = var.db_sterling_config.database_version

  settings {
    tier = var.db_sterling_config.tier

    user_labels = local.common_tags

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"
      }
    }

    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_user" "mysql_user" {
  name     = var.db_user
  instance = google_sql_database_instance.mysql_instance_sterling.name
  password = data.google_secret_manager_secret_version.db_password_version.secret_data
}

resource "google_sql_database" "default_db" {
  name     = local.sterling_database_name
  instance = google_sql_database_instance.mysql_instance_sterling.name
}

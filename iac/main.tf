data "google_project" "project" {}

resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "pubsub.googleapis.com",
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "storage.googleapis.com"
  ])
  service = each.key
}

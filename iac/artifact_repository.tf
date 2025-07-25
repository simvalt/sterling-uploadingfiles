resource "google_artifact_registry_repository" "docker_repo" {
  provider      = google
  location      = var.region
  repository_id = local.sterling_artifact_repo
  description   = "Repositorio Docker para Sterling App"
  format        = "DOCKER"


  labels = local.common_tags

  depends_on = [google_project_service.enabled_apis]
}

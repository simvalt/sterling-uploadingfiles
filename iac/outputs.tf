output "cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "region" {
  value = var.region
}

output "docker_repo_url" {
  value = "us-central1-docker.pkg.dev/${var.project_id}/hello-repo"
}
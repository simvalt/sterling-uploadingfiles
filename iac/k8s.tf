resource "google_container_cluster" "gke_cluster" {
  name     = local.gke_cluster_sterling
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network         = "default"
  subnetwork      = "default"
  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {}

  deletion_protection = false

  release_channel {
    channel = "REGULAR"
  }

  resource_labels = local.common_tags

  depends_on = [google_project_service.enabled_apis]
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.gke_cluster.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = local.common_tags
  }

  depends_on = [google_container_cluster.gke_cluster]
}

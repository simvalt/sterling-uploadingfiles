resource "google_pubsub_topic_iam_member" "allow_storage_to_publish" {
  topic  = local.bucket_topic_name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "allow_pubsub_upload" {
  bucket = local.bucket_name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:pubsub-listener@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_pubsub_topic" "bucket_topic" {
  name   = local.bucket_topic_name
  labels = local.common_tags
}

resource "google_storage_bucket" "bucket" {
  name     = local.bucket_name
  location = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  labels = merge(local.common_tags, {
    env     = var.env
    project = local.bucket_name
  })
}

resource "google_storage_notification" "bucket_to_pubsub" {
  bucket = local.bucket_name
  topic  = google_pubsub_topic.bucket_topic.id

  payload_format = "JSON_API_V1"
  event_types    = ["OBJECT_FINALIZE"]

  depends_on = [
    google_pubsub_topic.bucket_topic,
    google_pubsub_topic_iam_member.allow_storage_to_publish
  ]
}

resource "google_pubsub_subscription" "bucket_subscription" {
  name  = local.bucket_subscription_name
  topic = google_pubsub_topic.bucket_topic.name

  ack_deadline_seconds = 30

  labels = local.common_tags

  depends_on = [
    google_pubsub_topic.bucket_topic
  ]
}

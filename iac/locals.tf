locals {
  stack_envs  = split("_", var.stack_id)                              
  stack       = local.stack_envs[0]                                    
  project     = local.stack_envs[1]                                    
  environment = local.stack_envs[2]   


  common_tags = {
    stack_id    = var.stack_id
    project     = local.project
    environment = local.environment
    origin      = "terraform"
  }

  gke_cluster_sterling = "${local.project}-gke-${local.environment}"
  bucket_name = "${local.project}-bucket-tempfiles-${local.environment}"
  bucket_subscription_name = "${local.bucket_name}-subscription"
bucket_topic_name = "${local.bucket_name}-events"
sterling_artifact_repo= "${local.project}-repo-${local.environment}"
sterling_database_name = "${local.project}-db-mysql-${local.environment}"

}
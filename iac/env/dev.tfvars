project_id    = "gentera-proyects"
region        = "us-central1"
zone        = "us-central1-b"
stack_id  = "gentera_sterling_dev"
node_count    = 1
machine_type  = "e2-medium"
env           = "dev"
disk_size_gb  = 20
disk_type     = "pd-standard"
db_user     = "admin"

db_sterling_config = {
    tier = "db-f1-micro"
    database_version = "MYSQL_8_0"
}
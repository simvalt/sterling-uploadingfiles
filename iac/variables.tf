variable "project_id" {
  description = "ID del proyecto de GCP"
  type        = string
}

variable "region" {
  description = "Región para desplegar GKE"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Región específica para el clúster GKE"
  type        = string
  default     = "us-central1-b"
}

variable "stack_id" {
  description = "Nombre del clúster GKE"
  type        = string
}

variable "node_count" {
  description = "Número de nodos iniciales"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Tipo de instancia de nodo"
  type        = string
  default     = "e2-small"
}

variable "env" {
  description = "Etiqueta de entorno"
  type        = string
  default     = "dev"
}
variable "disk_size_gb" {
  description = "Tamaño del disco en GB"
  type        = number
}
variable "disk_type" {
  description = "Tipo de disco para los nodos"
  type        = string
}

variable "db_user" {
  type = string
}

variable "db_sterling_config" {
  description = "Configuración de la base de datos MySQL para Sterling"
  type = object({
    tier              = string
    database_version = string
  })
}
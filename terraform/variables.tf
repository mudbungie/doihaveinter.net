variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "region" {
  description = "OCI region (e.g., us-phoenix-1, sjc)"
  type        = string
  default     = "us-phoenix-1"
}

variable "availability_domain" {
  description = "Availability domain for container instance"
  type        = string
}

variable "container_image" {
  description = "OCIR image path for the container (e.g., sjc.ocir.io/<namespace>/get-ip:0.0.1)"
  type        = string
}

variable "ocir_namespace" {
  description = "OCIR namespace"
  type        = string
}

variable "ocir_user_email" {
  description = "Email for OCIR authentication"
  type        = string
}

variable "ocir_auth_token" {
  description = "Auth token for OCIR"
  type        = string
  sensitive   = true
}

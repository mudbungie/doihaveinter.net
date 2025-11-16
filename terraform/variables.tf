variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "region" {
  description = "OCI region (e.g., us-phoenix-1, sjc)"
  type        = string
  default     = "us-phoenix-1"
}

variable "function_image" {
  description = "OCIR image path for the function (e.g., phx.ocir.io/<namespace>/get-ip:0.0.1)"
  type        = string
}

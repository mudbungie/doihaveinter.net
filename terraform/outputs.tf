output "api_gateway_hostname" {
  description = "API Gateway hostname"
  value       = oci_apigateway_gateway.main.hostname
}

output "api_gateway_public_ip" {
  description = "API Gateway public IP address"
  value       = length(oci_apigateway_gateway.main.ip_addresses) > 0 ? oci_apigateway_gateway.main.ip_addresses[0].ip_address : null
}

output "endpoint_url" {
  description = "Full endpoint URL"
  value       = "https://${oci_apigateway_gateway.main.hostname}/ip"
}

output "health_check_url" {
  description = "Health check endpoint"
  value       = "https://${oci_apigateway_gateway.main.hostname}/health"
}

output "function_id" {
  description = "OCID of the deployed function"
  value       = oci_functions_function.get_ip.id
}

output "functions_application_id" {
  description = "OCID of the functions application"
  value       = oci_functions_application.main.id
}

output "log_group_id" {
  description = "OCID of the function log group"
  value       = oci_logging_log_group.functions.id
}

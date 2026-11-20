output "load_balancer_ip" {
  description = "Load balancer public IP address"
  value       = oci_network_load_balancer_network_load_balancer.main.ip_addresses[0].ip_address
}

output "endpoint_url" {
  description = "Full endpoint URL"
  value       = "http://${oci_network_load_balancer_network_load_balancer.main.ip_addresses[0].ip_address}/ip"
}

output "health_check_url" {
  description = "Health check endpoint"
  value       = "http://${oci_network_load_balancer_network_load_balancer.main.ip_addresses[0].ip_address}/health"
}

output "instance_id" {
  description = "OCID of the VM running the container"
  value       = oci_core_instance.get_ip.id
}

output "log_group_id" {
  description = "OCID of the container log group"
  value       = oci_logging_log_group.container.id
}

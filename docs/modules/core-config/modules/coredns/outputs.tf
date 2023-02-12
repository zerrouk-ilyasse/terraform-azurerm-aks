output "custom_config_map_name" {
  description = "Name of the CoreDNS custom ConfigMap."
  value       = local.custom_config_map_name
}

output "custom_config_map_namespace" {
  description = "Namespace of the CoreDNS custom ConfigMap."
  value       = var.namespace
}

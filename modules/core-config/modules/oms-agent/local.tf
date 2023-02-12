locals {
  log_data_collection_settings = <<-EOT
    [log_collection_settings]
       [log_collection_settings.schema]
          containerlog_schema_version = "v1"

       [log_collection_settings.stdout]
          enabled  = true
          exclude_namespaces = [${join(",", [for x in var.core_namespaces : "\"${x}\""])}]

       [log_collection_settings.stderr]
          enabled  = true
          exclude_namespaces = [${join(",", [for x in var.core_namespaces : "\"${x}\""])}]

       [log_collection_settings.env_var]
          enabled = true

       [log_collection_settings.enrich_container_logs]
          enabled = false

       [log_collection_settings.collect_all_kube_events]
          enabled = false
  EOT
}

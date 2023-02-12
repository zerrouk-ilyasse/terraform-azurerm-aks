locals {
  custom_config_map_name = "coredns-custom"

  coredns_custom_overwrite = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = local.custom_config_map_name
      namespace = var.namespace
      labels    = var.labels
    }
  }

  forward_zone_config = <<-EOT
    %{for zone, ip in var.forward_zones}
    ${zone}:53 {
      forward . ${ip}
    }
    %{endfor~}
  EOT

  resource_files = { for x in fileset(path.module, "resources/*.yaml") : basename(x) => "${path.module}/${x}" }
}

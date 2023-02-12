resource "kubectl_manifest" "resource_files" {
  for_each = local.resource_files

  yaml_body = file(each.value)

  server_side_apply = true
  wait              = true
}

resource "kubectl_manifest" "resource_objects" {
  for_each = { coredns_custom = local.coredns_custom_overwrite }

  yaml_body  = yamlencode(each.value)
  apply_only = true

  ignore_fields = ["data"]

  server_side_apply = true
  wait              = true
}

resource "kubernetes_config_map_v1_data" "onpremzones_server" {
  count = length(var.forward_zones) > 0 ? 1 : 0

  metadata {
    name      = local.custom_config_map_name
    namespace = var.namespace
  }

  data = {
    "onpremzones.server" = local.forward_zone_config
  }

  force = true
}

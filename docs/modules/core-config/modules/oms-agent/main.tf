resource "kubernetes_config_map" "default" {
  count = var.create_configmap ? 1 : 0

  metadata {
    name      = "container-azm-ms-agentconfig"
    namespace = var.namespace

    labels = var.labels
  }

  data = {
    schema-version               = "v1"
    config-version               = "v1"
    log-data-collection-settings = local.log_data_collection_settings
  }
}

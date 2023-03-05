# This version will never be less than 1.0.0-beta.21 as that's when it was added
resource "static_data" "creation_metadata" {
  data = {
    creation_date    = timestamp()
    creation_version = local.module_version
  }

  lifecycle {
    ignore_changes = [data]
  }
}

module "cluster" {
  source = "./modules/cluster"

  location                                                = var.location
  resource_group_name                                     = var.resource_group_name
  cluster_name                                            = var.cluster_name
  cluster_version_full                                    = local.cluster_version_full
  sku_tier_paid                                           = var.sku_tier_paid
  cluster_endpoint_public_access                          = var.cluster_endpoint_public_access
  cluster_endpoint_access_cidrs                           = var.cluster_endpoint_access_cidrs
  network_plugin                                          = var.network_plugin
  subnet_id                                               = local.subnet_id
  route_table_id                                          = local.route_table_id
  podnet_cidr_block                                       = var.podnet_cidr_block
  nat_gateway_id                                          = var.nat_gateway_id
  managed_outbound_ip_count                               = var.managed_outbound_ip_count
  managed_outbound_ports_allocated                        = var.managed_outbound_ports_allocated
  managed_outbound_idle_timeout                           = var.managed_outbound_idle_timeout
  admin_group_object_ids                                  = var.admin_group_object_ids
  bootstrap_name                                          = local.bootstrap_name
  bootstrap_vm_size                                       = local.bootstrap_vm_size
  control_plane_logging_external_workspace                = var.control_plane_logging_external_workspace
  control_plane_logging_external_workspace_id             = var.control_plane_logging_external_workspace_id
  control_plane_logging_workspace_categories              = var.control_plane_logging_workspace_categories
  control_plane_logging_workspace_retention_enabled       = var.control_plane_logging_workspace_retention_enabled
  control_plane_logging_workspace_retention_days          = var.control_plane_logging_workspace_retention_days
  control_plane_logging_storage_account_enabled           = var.control_plane_logging_storage_account_enabled
  control_plane_logging_storage_account_id                = var.control_plane_logging_storage_account_id
  control_plane_logging_storage_account_categories        = var.control_plane_logging_storage_account_categories
  control_plane_logging_storage_account_retention_enabled = var.control_plane_logging_storage_account_retention_enabled
  control_plane_logging_storage_account_retention_days    = var.control_plane_logging_storage_account_retention_days
  fips                                                    = local.experimental_fips
  maintenance_window_offset                               = var.maintenance_window_offset
  maintenance_window_allowed_days                         = var.maintenance_window_allowed_days
  maintenance_window_allowed_hours                        = var.maintenance_window_allowed_hours
  maintenance_window_not_allowed                          = var.maintenance_window_not_allowed
  oms_agent                                               = local.experimental_oms_agent
  oms_agent_log_analytics_workspace_id                    = local.experimental_oms_agent_log_analytics_workspace_id
  windows_support                                         = local.experimental_windows_support
  cluster_tags                                            = local.cluster_tags
  tags                                                    = local.tags
  timeouts                                                = local.timeouts
  experimental                                            = var.experimental
}

module "rbac" {
  source = "./modules/rbac"

  azure_env     = var.azure_env
  cluster_id    = module.cluster.id
  rbac_bindings = local.rbac_bindings
  labels        = local.labels

  depends_on = [
    module.cluster
  ]
}

module "node_groups" {
  source = "./modules/node-groups"

  subscription_id      = local.subscription_id
  location             = var.location
  resource_group_name  = var.resource_group_name
  cluster_id           = module.cluster.id
  cluster_name         = var.cluster_name
  cluster_version_full = local.cluster_version_full
  network_plugin       = var.network_plugin
  subnet_id            = local.subnet_id
  availability_zones   = local.availability_zones
  bootstrap_name       = local.bootstrap_name
  bootstrap_vm_size    = local.bootstrap_vm_size
  node_groups          = merge(local.node_groups, local.system_node_groups)
  fips                 = local.experimental_fips
  labels               = local.labels
  tags                 = local.tags
  experimental         = var.experimental

  avoid_bootstrap_node_group_hack = var.avoid_bootstrap_node_group_hack

  depends_on = [
    module.cluster
  ]
}


module "core_config" {
  source = "./modules/core-config"
  count  = var.avoid_core_config_module_call ? 0 : 1

  azure_env           = var.azure_env
  tenant_id           = local.tenant_id
  subscription_id     = local.subscription_id
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id            = local.subnet_id
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  network_plugin  = var.network_plugin
  cluster_oidc_issuer_url = module.cluster.oidc_issuer_url
  ingress_node_group = local.ingress_node_group

  availability_zones = local.availability_zones

  avoid_statefulset_ha_zones_replicas = var.avoid_statefulset_ha_zones_replicas

  kubelet_identity_id      = module.cluster.kubelet_identity.object_id
  node_resource_group_name = module.cluster.node_resource_group_name

  dns_resource_group_lookup = var.dns_resource_group_lookup

  core_services_config = var.core_services_config

  control_plane_log_analytics_workspace_id                       = module.cluster.control_plane_log_analytics_workspace_id
  control_plane_log_analytics_workspace_different_resource_group = var.control_plane_logging_external_workspace_different_resource_group
  oms_agent                                                      = local.experimental_oms_agent
  oms_agent_log_analytics_workspace_id                           = local.experimental_oms_agent_log_analytics_workspace_id
  oms_agent_log_analytics_workspace_different_resource_group     = local.experimental_oms_agent_log_analytics_workspace_different_resource_group
  oms_agent_create_configmap                                     = local.experimental_oms_agent_create_configmap

  # storage_account_id = module.cluster.data_storage_account_id

  labels = local.labels
  tags   = local.tags

  experimental = var.experimental

  depends_on = [
    module.rbac,
    module.node_groups
  ]
}

resource "kubernetes_config_map" "terraform_modules" {
  metadata {
    name      = "terraform-modules"
    namespace = "default"
  }

  data = {
    (local.module_name) = local.module_version
  }

  depends_on = [
    module.cluster,
    module.rbac,
    module.node_groups,
    module.core_config
  ]
}

resource "kubernetes_config_map" "default" {
  metadata {
    name      = "tfmodule-${local.module_name}"
    namespace = "kube-system"

    labels = local.labels
  }

  data = {
    version = local.module_version

    config = jsonencode({
      cluster = {
        name    = var.cluster_name
        version = local.cluster_version_full
      }
    })
  }

  depends_on = [
    module.core_config
  ]
}

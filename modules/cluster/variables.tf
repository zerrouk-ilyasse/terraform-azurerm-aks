variable "location" {
  description = "Azure region in which to build resources."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to deploy the AKS cluster service to, must already exist."
  type        = string
}

variable "cluster_name" {
  description = "Name of the Azure Kubernetes managed cluster to create, also used as a prefix in names of related resources."
  type        = string
}

variable "cluster_version_full" {
  description = "The full Kubernetes version of the Azure Kubernetes managed cluster."
  type        = string
}

variable "network_plugin" {
  description = "Kubernetes Network Plugin, \"kubenet\" & \"azure\" are supported."
  type        = string
}

variable "sku_tier_paid" {
  description = "If the cluster control plane SKU tier should be paid or free. The paid tier has a financially-backed uptime SLA."
  type        = bool
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Azure Kubernetes managed cluster public API server endpoint is enabled."
  type        = bool
}

variable "cluster_endpoint_access_cidrs" {
  description = "List of CIDR blocks which can access the Azure Kubernetes managed cluster API server endpoint."
  type        = list(string)
}

variable "subnet_id" {
  description = "ID of the subnet."
  type        = string
}

variable "route_table_id" {
  description = "ID of the route table."
  type        = string
}

variable "podnet_cidr_block" {
  description = "CIDR range for pod IP addresses when using the kubenet network plugin."
  type        = string
}

variable "nat_gateway_id" {
  description = "ID of a user-assigned NAT Gateway to use for cluster egress traffic, if not set a cluster managed load balancer will be used."
  type        = string
}

variable "managed_outbound_ip_count" {
  description = "Count of desired managed outbound IPs for the cluster managed load balancer. Ignored if NAT gateway is specified, must be between 1 and 100 inclusive."
  type        = number
}

variable "managed_outbound_ports_allocated" {
  description = "Number of desired SNAT port for each VM in the cluster managed load balancer. Ignored if NAT gateway is specified, must be between 0 and 64000 inclusive."
  type        = number
}

variable "managed_outbound_idle_timeout" {
  description = "Desired outbound flow idle timeout in seconds for the cluster managed load balancer. Ignored if NAT gateway is specified, must be between 240 and 7200 inclusive."
  type        = number
}

variable "admin_group_object_ids" {
  description = "AD Object IDs to be added to the cluster admin group, if not set the current user will be made a cluster administrator."
  type        = list(string)
}

variable "bootstrap_name" {
  description = "Name to use for the bootstrap node group."
  type        = string
}

variable "bootstrap_vm_size" {
  description = "VM size to use for the bootstrap node group."
  type        = string
}

variable "control_plane_logging_external_workspace" {
  description = "If true, the log analytics workspace referenced in control_plane_logging_external_workspace_id will be used to store the logs. Otherwise a log analytics workspace will be created to store the logs."
  type        = bool
}

variable "control_plane_logging_external_workspace_id" {
  description = "ID of the log analytics workspace to send control plane logs to if control_plane_logging_external_workspace is true."
  type        = string
}

variable "control_plane_logging_workspace_categories" {
  description = "The control plane log categories to send to the log analytics workspace."
  type        = string
}

variable "control_plane_logging_workspace_retention_enabled" {
  description = "If the control plane logs being sent to log analytics should have a retention specified, if not set the log analytics workspace default retention will be used."
  type        = bool
}

variable "control_plane_logging_workspace_retention_days" {
  description = "How long the logs should be retained by the log analytics workspace if control_plane_logging_workspace_retention_enabled is true, in days."
  type        = number
}

variable "control_plane_logging_storage_account_enabled" {
  description = "If true, cluster control plane logs will be sent to the storage account referenced in control_plane_logging_storage_account_id as well as the default log analytics workspace."
  type        = bool
}

variable "control_plane_logging_storage_account_id" {
  description = "ID of the storage account to add cluster control plane logs to if control_plane_logging_storage_account_id is true. "
  type        = string
}

variable "control_plane_logging_storage_account_categories" {
  description = "The control plane log categories to send to the storage account."
  type        = string
}

variable "control_plane_logging_storage_account_retention_enabled" {
  description = "If true, the control plane logs being sent to log analytics will use the retention specified in control_plane_logging_workspace_retention_days otherwise the log analytics workspace default retention will be used."
  type        = bool
}

variable "control_plane_logging_storage_account_retention_days" {
  description = "How long the logs should be retained by the log analytics workspace if control_plane_logging_workspace_retention_enabled is true, in days."
  type        = number
}

variable "fips" {
  description = "If the node groups should be FIPS 140-2 enabled."
  type        = bool
}

variable "maintenance_window_offset" {
  description = "Maintenance window offset to utc."
  type        = number
}

variable "maintenance_window_allowed_days" {
  description = "List of allowed days covering the maintenance window."
  type        = list(string)
}

variable "maintenance_window_allowed_hours" {
  description = "List of allowed hours covering the maintenance window."
  type        = list(number)
}

variable "maintenance_window_not_allowed" {
  description = "Array of not allowed blocks including start and end times in rfc3339 format. A not allowed block takes priority if it overlaps an allowed blocks in a maintenance window."
  type = list(object({
    start = string
    end   = string
  }))
}

variable "oms_agent" {
  description = "If the OMS agent addon should be installed."
  type        = bool
}

variable "oms_agent_log_analytics_workspace_id" {
  description = "ID of the log analytics workspace for the OMS agent."
  type        = string
}

variable "windows_support" {
  description = "If the Kubernetes cluster should support Windows nodes."
  type        = bool
}

variable "cluster_tags" {
  description = "Tags to apply to the cluster."
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
}

variable "timeouts" {
  description = "Timeout configuration."
  type = object({
    cluster_read   = number
    cluster_modify = number
  })
}

# tflint-ignore: terraform_unused_declarations
variable "experimental" {
  description = "Provide experimental feature flag configuration."
  type        = any
}

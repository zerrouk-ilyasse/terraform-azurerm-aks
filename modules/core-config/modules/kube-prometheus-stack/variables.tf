variable "subscription_id" {
  description = "ID of the subscription."
  type        = string
  nullable    = false
}

variable "location" {
  description = "Azure region in which the AKS cluster is located."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the AKS cluster."
  type        = string
  nullable    = false
}

variable "cluster_name" {
  description = "Name of the Azure Kubernetes managed cluster."
  type        = string
  nullable    = false
}

variable "workload_identity" {
  description = "If the cluster has workload identity enabled."
  type        = bool
}

variable "cluster_oidc_issuer_url" {
  description = "The URL of the cluster OIDC issuer."
  type        = string
}

variable "namespace" {
  description = "Namespace to install the Kubernetes resources into."
  type        = string
  nullable    = false
}

variable "labels" {
  description = "Labels to be applied to all Kubernetes resources."
  type        = map(string)
  nullable    = false
}

variable "subnet_id" {
  description = "ID of the subnet."
  type        = string
  nullable    = false
}

variable "zones" {
  description = "The number of zones this chart should be run on."
  type        = number
  nullable    = false
}

variable "prometheus_remote_write" {
  description = "Remote Prometheus endpoints to write metrics to."
  type        = any
  default     = []
  nullable    = false
}

variable "alertmanager_smtp_host" {
  description = "The SMTP host to use for Alert Manager."
  type        = string
  nullable    = false
}

variable "alertmanager_smtp_from" {
  description = "The SMTP from address to use for Alert Manager."
  type        = string
  nullable    = false
}

variable "alertmanager_receivers" {
  description = "Alertmanager recievers to add to the default null, will always be a list."
  type = list(object({
    name              = string
    email_configs     = optional(any, [])
    opsgenie_configs  = optional(any, [])
    pagerduty_configs = optional(any, [])
    pushover_configs  = optional(any, [])
    slack_configs     = optional(any, [])
    sns_configs       = optional(any, [])
    victorops_configs = optional(any, [])
    webhook_configs   = optional(any, [])
    wechat_configs    = optional(any, [])
    telegram_configs  = optional(any, [])
  }))
  nullable = false
  default  = []
}

variable "alertmanager_routes" {
  description = "Alertmanager routes, will always be a list."
  type = list(object({
    receiver            = string
    group_by            = optional(list(string), [])
    continue            = optional(bool, false)
    matchers            = list(string)
    group_wait          = optional(string, "30s")
    group_interval      = optional(string, "5m")
    repeat_interval     = optional(string, "12h")
    mute_time_intervals = optional(list(string), [])
    # active_time_intervals = optional(list(string), [])
  }))
  nullable = false
  default  = []
}

variable "grafana_admin_password" {
  description = "The Grafana admin password."
  type        = string
  nullable    = false
  default     = "changeme"
}

variable "grafana_additional_plugins" {
  description = "Additional Grafana plugins to install."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "grafana_additional_data_sources" {
  description = "Additional Grafana data sources to add, will always be a list."
  type        = any
  nullable    = false
  default     = []
}

variable "ingress_class_name" {
  description = "The ingress class for ingress resources."
  type        = string
  nullable    = false
}

variable "ingress_domain" {
  description = "The domain to use for ingress resources."
  type        = string
  nullable    = false
}

variable "ingress_subdomain_suffix" {
  description = "The suffix for the ingress subdomain."
  type        = string
  nullable    = false
}

variable "ingress_annotations" {
  description = "The annotations for ingress resources."
  type        = map(string)
  nullable    = false
}

variable "control_plane_log_analytics_workspace_id" {
  description = "ID of the log analytics workspace for the AKS cluster control plane."
  type        = string
  nullable    = false
}

variable "control_plane_log_analytics_workspace_different_resource_group" {
  description = "If true, the log analytics workspace referenced in control_plane_logging_external_workspace_id is created in a different resource group to the cluster."
  type        = bool
  nullable    = false
}

variable "oms_agent" {
  description = "If the OMS agent addon should be installed."
  type        = bool
  nullable    = false
}

variable "oms_agent_log_analytics_workspace_id" {
  description = "ID of the log analytics workspace for the OMS agent."
  type        = string
  nullable    = true
}

variable "oms_agent_log_analytics_workspace_different_resource_group" {
  description = "If the oms agent log analytics workspace is in a different resource group to the cluster."
  type        = bool
  nullable    = false
}

variable "skip_crds" {
  description = "Skip installing the CRDs as part of the module."
  type        = bool
  nullable    = false
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  nullable    = false
}

variable "experimental_prometheus_memory_override" {
  description = "Provide experimental feature flag configuration."
  type        = string
  nullable    = true
}

variable "subscription_id" {
  description = "ID of the subscription."
  type        = string
  
}

variable "location" {
  description = "Azure region in which the AKS cluster is located."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the AKS cluster."
  type        = string
  
}

variable "cluster_name" {
  description = "Name of the Azure Kubernetes managed cluster."
  type        = string
  
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
  
}

variable "labels" {
  description = "Labels to be applied to all Kubernetes resources."
  type        = map(string)
  
}

variable "subnet_id" {
  description = "ID of the subnet."
  type        = string
  
}

variable "zones" {
  description = "The number of zones this chart should be run on."
  type        = number
  
}

variable "prometheus_remote_write" {
  description = "Remote Prometheus endpoints to write metrics to."
  type        = any
  default     = []
  
}

variable "alertmanager_smtp_host" {
  description = "The SMTP host to use for Alert Manager."
  type        = string
  
}

variable "alertmanager_smtp_from" {
  description = "The SMTP from address to use for Alert Manager."
  type        = string
  
}

variable "alertmanager_receivers" {
  description = "Alertmanager recievers to add to the default null, will always be a list."
  type = list(object({
    name              = string
    email_configs     = any
    opsgenie_configs  = any
    pagerduty_configs = any
    pushover_configs  = any
    slack_configs     = any
    sns_configs       = any
    victorops_configs = any
    webhook_configs   = any
    wechat_configs    = any
    telegram_configs  = any
  }))
  
  default  = []
}

variable "alertmanager_routes" {
  description = "Alertmanager routes, will always be a list."
  type = list(object({
    receiver            = string
    group_by            = any
    continue            = any
    matchers            = list(string)
    group_wait          = any
    group_interval      = any
    repeat_interval     = any
    mute_time_intervals = any
    # active_time_intervals = optional(list(string), [])
  }))
  
  default  = []
}

variable "grafana_admin_password" {
  description = "The Grafana admin password."
  type        = string
  
  default     = "changeme"
}

variable "grafana_additional_plugins" {
  description = "Additional Grafana plugins to install."
  type        = list(string)
  
  default     = []
}

variable "grafana_additional_data_sources" {
  description = "Additional Grafana data sources to add, will always be a list."
  type        = any
  
  default     = []
}

variable "ingress_class_name" {
  description = "The ingress class for ingress resources."
  type        = string
  
}

variable "ingress_domain" {
  description = "The domain to use for ingress resources."
  type        = string
  
}

variable "ingress_subdomain_suffix" {
  description = "The suffix for the ingress subdomain."
  type        = string
  
}

variable "ingress_annotations" {
  description = "The annotations for ingress resources."
  type        = map(string)
  
}

variable "control_plane_log_analytics_workspace_id" {
  description = "ID of the log analytics workspace for the AKS cluster control plane."
  type        = string
  
}

variable "control_plane_log_analytics_workspace_different_resource_group" {
  description = "If true, the log analytics workspace referenced in control_plane_logging_external_workspace_id is created in a different resource group to the cluster."
  type        = bool
  
}

variable "oms_agent" {
  description = "If the OMS agent addon should be installed."
  type        = bool
  
}

variable "oms_agent_log_analytics_workspace_id" {
  description = "ID of the log analytics workspace for the OMS agent."
  type        = string
  
}

variable "oms_agent_log_analytics_workspace_different_resource_group" {
  description = "If the oms agent log analytics workspace is in a different resource group to the cluster."
  type        = bool
  
}

variable "skip_crds" {
  description = "Skip installing the CRDs as part of the module."
  type        = bool
  
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  
}

variable "experimental_prometheus_memory_override" {
  description = "Provide experimental feature flag configuration."
  type        = string
  default     =""
}

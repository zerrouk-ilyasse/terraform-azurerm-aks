variable "namespace" {
  description = "Namespace to install the Kubernetes resources into."
  type        = string
}

variable "labels" {
  description = "Labels to be applied to all Kubernetes resources."
  type        = map(string)
}

variable "core_namespaces" {
  description = "Namespaces belonging to the core cluster implementation."
  type        = list(string)
}

variable "create_configmap" {
  description = "If the OMS agent ConfigMap should be created with default settings."
  type        = bool
}

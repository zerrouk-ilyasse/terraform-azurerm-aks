variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "script_path" {
  description = "Path to the script to run."
  type        = string
}

variable "environment" {
  description = "Environment for the script run."
  type        = map(string)
}

variable "resource_group_name" {
  description = "resource_group_name"
  default     = ""
}

variable "location" {
  description = "location"
  default     = ""
}

variable "public_ssh_key" {
  description = "public_ssh_key"
  default     = ""
}

variable "vnet_address_prefix" {
  description = "vnet_address_prefix"
  default     = ""
}

variable "subnet_address_prefix" {
  description = "subnet_address_prefix"
  default     = ""
}

variable "agents_count" {
  description = "agents_count"
  default     = ""
}

variable "agents_size" {
  description = "agents_size"
  default     = ""
}

variable "kubernetes_version" {
  description = "kubernetes_version"
  default     = null
}

variable "service_mesh_type" {
  description = "service_mesh_type"
  default     = ""
}

variable "kube_config_raw" {
  description = "kube_config_raw"
  default     = ""
}

variable "bootstrap_repo_url" {
  type        = string
  description = "ArgoCD bootstrap repo"
  default     = ""
}

variable "bootstrap_repo_path" {
  type        = string
  description = "ArgoCD bootstrap repo folder"
  default     = ""
}

variable "bootstrap_repo_branch" {
  type        = string
  description = "ArgoCD bootstrap repo branch"
  default     = ""
}

variable "bootstrap_argo_project" {
  type        = string
  description = "ArgoCD bootstrap project"
  default     = ""
}

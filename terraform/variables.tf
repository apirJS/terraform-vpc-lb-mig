variable "path_to_serviceaccountkey" {
  type        = string
  description = "Path to your serviceaccountkey.json"
}

variable "project_id" {
  type        = string
  description = "example: qwiklabs-19218313"
}

variable "instance_group_eu_region" {
  type        = string
  description = "example: europe-west3"
}

variable "instance_group_eu_cidr" {
  type        = string
  description = "example: 10.100.10.0/24"
}

variable "instance_group_asia_region" {
  type        = string
  description = "example: asia-southeast1"
}

variable "instance_group_asia_cidr" {
  type        = string
  description = "example: 10.100.20.0/24"
}

variable "auditors" {
  type = list(object({
    email = string
    type  = string
  }))
  description = "auditors for this architecture"
}

variable "dashboard_display_name" {
  type        = string
  description = "example: My Dashboard"
}

variable "instance_startup_script_url" {
  type        = string
  description = "example: gs://bucket/startup.sh"
}


variable "auditor_roles" {
  type        = list(string)
  description = "example: ['roles/compute.viewer', 'roles/compute.networkViewer']"
}

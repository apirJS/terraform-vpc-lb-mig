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

variable "default_startup_script_url" {
  type        = string
  description = "example: gs://bucket/object.sh"
}

variable "auditor_email" {
  type        = string
  description = "people who can audit this architecture"
}

variable "auditor_type" {
  type        = string
  description = "the type of the auditor email. example: user, group, serviceAccount."
}

variable "dashboard_display_name" {
  type        = string
  description = "example: My Dashboard"
}


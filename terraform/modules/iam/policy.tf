variable "auditor_email" {}
variable "auditor_type" {}
variable "project_id" {}

resource "google_project_iam_custom_role" "custom_role" {
  project     = var.project_id
  role_id     = "architectureAuditor"
  title       = "Architecture Auditor"
  description = "A custom role for auditing this architecture"
  permissions = [
    "compute.projects.get",
    "compute.networks.get",
    "compute.networks.list",
    "compute.routers.list",
    "compute.routers.get",
    "compute.instanceTemplates.get",
    "compute.instanceTemplates.list",
    "compute.autoscalers.get",
    "compute.autoscalers.list",
    "compute.instanceGroupManagers.get",
    "compute.instanceGroupManagers.list",
    "compute.targetPools.get",
    "compute.targetPools.list",
    "iam.roles.get",
    "compute.firewalls.get",
    "compute.firewalls.list",
    "compute.backendServices.get",
    "compute.backendServices.list",
    "compute.regionBackendServices.get",
    "compute.regionBackendServices.list",
    "compute.forwardingRules.get",
    "compute.forwardingRules.list",
    "compute.globalAddresses.get",
    "compute.globalAddresses.list",
    "compute.globalForwardingRules.get",
    "compute.globalForwardingRules.list",
    "compute.urlMaps.get",
    "compute.urlMaps.list",
    "compute.targetHttpProxies.get",
    "compute.targetHttpProxies.list",
    "compute.healthChecks.get",
    "compute.healthChecks.list",
    "compute.routers.get",
    "compute.routers.list",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "monitoring.dashboards.get",
    "monitoring.dashboards.list",
  ]
}

resource "google_project_iam_member" "auditor" {
  project = var.project_id
  member  = "${var.auditor_type}:${var.auditor_email}"
  role    = google_project_iam_custom_role.custom_role.id
}

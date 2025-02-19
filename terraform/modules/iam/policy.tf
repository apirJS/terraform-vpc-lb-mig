variable "auditors" {}
variable "auditor_roles" {}
variable "project_id" {}
locals {
  auditor_assignments = flatten([
    for auditor in var.auditors : [
      for role in var.auditor_roles : {
        email = auditor.email
        type  = auditor.type
        role  = role
      }
    ]
  ])
}

resource "google_project_iam_member" "auditor" {
  for_each = {
    for assignment in local.auditor_assignments :
    "${assignment.email}-${assignment.role}" => assignment
  }

  project = var.project_id
  member  = "${each.value.type}:${each.value.email}"
  role    = each.value.role
}

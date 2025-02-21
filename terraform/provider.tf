terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.20.0"
    }
  }
}

provider "google" {
  project         = var.project_id
  credentials     = file("${path.module}/${var.path_to_serviceaccountkey}")
  request_timeout = "20m"
}

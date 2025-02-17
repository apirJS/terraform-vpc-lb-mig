variable "project_id" {}
variable "instance_group_eu_region" {}
variable "instance_group_asia_region" {}
variable "instance_group_eu_cidr" {}
variable "instance_group_asia_cidr" {}


resource "google_compute_network" "myvpc" {
  project                 = var.project_id
  name                    = "myvpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet_eu" {
  name          = "${google_compute_network.myvpc.name}-subnet-eu"
  network       = google_compute_network.myvpc.id
  region        = var.instance_group_eu_region
  ip_cidr_range = var.instance_group_eu_cidr
}

resource "google_compute_subnetwork" "subnet_asia" {
  name          = "${google_compute_network.myvpc.name}-subnet-asia"
  network       = google_compute_network.myvpc.id
  region        = var.instance_group_asia_region
  ip_cidr_range = var.instance_group_asia_cidr
}

resource "google_compute_firewall" "allow_http" {
  project       = var.project_id
  direction     = "INGRESS"
  name          = "allow-http"
  network       = google_compute_network.myvpc.name
  description   = "Creates firewall rule targeting tagged instances"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["allow-http"]
}

resource "google_compute_firewall" "allow_health_check" {
  project       = var.project_id
  direction     = "INGRESS"
  name          = "allow-health-check"
  network       = google_compute_network.myvpc.name
  description   = "Creates firewall rule targeting tagged instances"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]

  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}

output "myvpc_id" {
  value = google_compute_network.myvpc.id
}

output "subnet_eu_id" {
  value = google_compute_subnetwork.subnet_eu.id
}

output "subnet_asia_id" {
  value = google_compute_subnetwork.subnet_asia.id
}

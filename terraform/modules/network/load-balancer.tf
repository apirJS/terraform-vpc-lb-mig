variable "project_id" {}
variable "instance_group_eu_region" {}
variable "instance_group_asia_region" {}
variable "instance_group_eu_cidr" {}
variable "instance_group_asia_cidr" {}
variable "instance_group_eu" {}
variable "instance_group_asia" {}


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
  network       = google_compute_network.myvpc.id
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
  network       = google_compute_network.myvpc.id
  description   = "Creates firewall rule targeting tagged instances"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}


# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
resource "google_compute_router" "router_eu" {
  name    = "${google_compute_network.myvpc.name}-router-eu"
  network = google_compute_network.myvpc.id
  region  = var.instance_group_eu_region
}
resource "google_compute_router" "router_asia" {
  name    = "${google_compute_network.myvpc.name}-router-asia"
  network = google_compute_network.myvpc.id
  region  = var.instance_group_asia_region
}

module "cloud-nat-eu" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 5.0"
  router     = google_compute_router.router_eu.name
  project_id = var.project_id
  region     = var.instance_group_eu_region
  name       = "${google_compute_network.myvpc.name}-cloud-nat-eu"
}

module "cloud-nat-asia" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 5.0"
  router     = google_compute_router.router_asia.name
  project_id = var.project_id
  region     = var.instance_group_asia_region
  name       = "${google_compute_network.myvpc.name}-cloud-nat-asia"
}

resource "google_compute_global_address" "lb_ip_address" {
  name = "lb-ip-address"
}

resource "google_compute_backend_service" "lb_backend_eu" {
  name                  = "lb-backend-eu"
  protocol              = "HTTP"
  port_name             = "my-port"
  load_balancing_scheme = "EXTERNAL"
}

# [START cloudloadbalancing_ext_http_gce]
module "external-lb-http" {
  source  = "terraform-google-modules/lb-http/google"
  version = "~> 12.0"
  name    = "lb"
  project = var.project_id
  target_tags = [
    "allow-health-check"
  ]
  firewall_networks = [google_compute_network.myvpc.name]
  backends = {
    default = {

      protocol    = "HTTP"
      port        = 80
      port_name   = "http"
      timeout_sec = 10
      enable_cdn  = false

      health_check = {
        request_path = "/"
        port         = 80
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group = var.instance_group_eu
        },
        {
          group = var.instance_group_asia
        },
      ]

      iap_config = {
        enable = false
      }
    }
  }
}
# [END cloudloadbalancing_ext_http_gce]

output "myvpc_id" {
  value = google_compute_network.myvpc.id
}

output "subnet_eu_id" {
  value = google_compute_subnetwork.subnet_eu.id
}

output "subnet_asia_id" {
  value = google_compute_subnetwork.subnet_asia.id
}

output "lb_external_ip" {
  value = module.external-lb-http.external_ip
}

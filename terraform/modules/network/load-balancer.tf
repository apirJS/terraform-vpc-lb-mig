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

##### IF YOU WANT TO USE EXTERNAL MODULE
# [START cloudloadbalancing_ext_http_gce]
# module "external-lb-http" {
#   source  = "terraform-google-modules/lb-http/google"
#   version = "~> 12.0"
#   name    = "mylb"
#   project = var.project_id
#   target_tags = [
#     "allow-health-check"
#   ]
#   firewall_networks = [google_compute_network.myvpc.name]


#   backends = {
#     default = {

#       protocol    = "HTTP"
#       port        = 80
#       port_name   = "http"
#       timeout_sec = 10
#       enable_cdn  = false

#       health_check = {
#         request_path = "/"
#         port         = 80
#       }

#       log_config = {
#         enable      = true
#         sample_rate = 1.0
#       }

#       groups = [
#         {
#           group = var.instance_group_eu
#         },
#         {
#           group = var.instance_group_asia
#         },
#       ]

#       iap_config = {
#         enable = false
#       }
#     }
#   }
# }
# [END cloudloadbalancing_ext_http_gce]

resource "google_compute_health_check" "http_health_check" {
  name = "http-health-check"
  http_health_check {
    port = 80
  }
}

resource "google_compute_backend_service" "backend" {
  name                  = "backend-service"
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.http_health_check.self_link]

  # EUROPE
  backend {
    group                 = var.instance_group_eu
    balancing_mode        = "RATE"
    max_rate_per_instance = 50
  }
  # ASIA
  backend {
    group                 = var.instance_group_asia
    balancing_mode        = "RATE"
    max_rate_per_instance = 50
  }

  log_config {
    enable = true
  }

  iap {
    enabled = false
  }
}

resource "google_compute_ssl_certificate" "cert" {
  certificate = file("${path.module}/../../certs/certificate.crt")
  private_key = file("${path.module}/../../certs/private.key")
  name        = "ssl-certificate"
}

resource "google_compute_url_map" "url_map" {
  name            = "my-lb"
  default_service = google_compute_backend_service.backend.self_link
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_ssl_certificate.cert.self_link]
}

resource "google_compute_global_forwarding_rule" "forwarding_rule_http" {
  name        = "forwarding-rule-http"
  target      = google_compute_target_http_proxy.http_proxy.self_link
  ip_protocol = "TCP"
  port_range  = "80"
}
resource "google_compute_global_forwarding_rule" "forwarding_rule_https" {
  name        = "forwarding-rule-https"
  target      = google_compute_target_https_proxy.https_proxy.self_link
  ip_protocol = "TCP"
  port_range  = "443"
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

output "lb_external_ip" {
  value = google_compute_global_forwarding_rule.forwarding_rule_http.ip_address
}

variable "myvpc_id" {}
variable "subnet_eu_id" {}
variable "subnet_asia_id" {}
variable "instance_group_eu_region" {}
variable "instance_group_asia_region" {}
variable "instance_startup_script_url" {}

resource "google_compute_instance_template" "instance_template_eu" {
  tags         = ["allow-http", "allow-health-check", "allow-ssh"]
  machine_type = "f1-micro"

  scheduling {
    automatic_restart = true
  }

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.myvpc_id
    subnetwork = var.subnet_eu_id
  }

  metadata = {
    startup-script-url = var.instance_startup_script_url
  }
}

resource "google_compute_instance_template" "instance_template_asia" {
  tags         = ["allow-http", "allow-health-check", "allow-ssh"]
  machine_type = "f1-micro"

  scheduling {
    automatic_restart = true
  }

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.myvpc_id
    subnetwork = var.subnet_asia_id
  }

  metadata = {
    startup-script-url = var.instance_startup_script_url
  }
}
resource "google_compute_region_instance_group_manager" "instance_group_eu" {
  name               = "instance-group-eu-${var.instance_group_eu_region}"
  wait_for_instances = false
  target_size        = 1
  region             = var.instance_group_eu_region
  named_port {
    name = "http"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.instance_template_eu.id
    name              = "eu"
  }

  base_instance_name = "vm-eu"
}

resource "google_compute_region_instance_group_manager" "instance_group_asia" {
  name               = "instance-group-asia-${var.instance_group_asia_region}"
  wait_for_instances = false
  target_size        = 1
  region             = var.instance_group_asia_region
  named_port {
    name = "http"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.instance_template_asia.id
    name              = "asia"
  }

  base_instance_name = "vm-asia"
}

resource "google_compute_region_autoscaler" "autoscaler_eu" {
  name   = "autoscaler-eu"
  target = google_compute_region_instance_group_manager.instance_group_eu.id
  region = var.instance_group_eu_region

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}

resource "google_compute_region_autoscaler" "autoscaler_asia" {
  name   = "autoscaler-asia"
  target = google_compute_region_instance_group_manager.instance_group_asia.id
  region = var.instance_group_asia_region
  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}

output "instance_group_eu" {
  value = google_compute_region_instance_group_manager.instance_group_eu.instance_group
}
output "instance_group_asia" {
  value = google_compute_region_instance_group_manager.instance_group_asia.instance_group
}

output "instance_group_eu_name" {
  value = google_compute_region_instance_group_manager.instance_group_eu.name
}
output "instance_group_asia_name" {
  value = google_compute_region_instance_group_manager.instance_group_asia.name
}

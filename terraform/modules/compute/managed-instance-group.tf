variable "myvpc_id" {}
variable "subnet_eu_id" {}
variable "subnet_asia_id" {}
variable "startup_script_url" {}

resource "google_compute_instance_template" "instance_template_eu" {
  name         = "instance_template_eu"
  tags         = ["allow-https"]
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
    startup-script-url = "gs://cloud-training/gcpnet/httplb/startup.sh"
  }
}

resource "google_compute_instance_template" "instance_template_asia" {
  name         = "instance_template_asia"
  tags         = ["allow-https"]
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
    startup-script-url = "gs://cloud-training/gcpnet/httplb/startup.sh"
  }
}

resource "google_compute_instance_group_manager" "instance_group_eu" {
  name               = "instance_group_eu"
  wait_for_instances = false
  target_size        = 2
  version {
    instance_template = google_compute_instance_template.instance_template_eu.id
  }

  base_instance_name = "vm-eu"
}

resource "google_compute_instance_group_manager" "instance_group_asia" {
  name               = "instance_group_asia"
  wait_for_instances = false
  target_size        = 2
  version {
    instance_template = google_compute_instance_template.instance_template_asia.id
  }

  base_instance_name = "vm-asia"
}

resource "null_resource" "enable_APIs" {
  provisioner "local-exec" {
    command     = "gcloud services enable compute.googleapis.com"
    working_dir = path.module
  }
}

module "network" {
  source                     = "./modules/network"
  project_id                 = var.project_id
  instance_group_eu_region   = var.instance_group_eu_region
  instance_group_asia_region = var.instance_group_asia_region
  instance_group_eu_cidr     = var.instance_group_eu_cidr
  instance_group_asia_cidr   = var.instance_group_asia_cidr
  instance_group_eu          = module.compute.instance_group_eu
  instance_group_asia        = module.compute.instance_group_asia
}

module "compute" {
  source                     = "./modules/compute"
  myvpc_id                   = module.network.myvpc_id
  subnet_eu_id               = module.network.subnet_eu_id
  subnet_asia_id             = module.network.subnet_asia_id
  startup_script_url         = var.default_startup_script_url
  instance_group_asia_region = var.instance_group_asia_region
  instance_group_eu_region   = var.instance_group_eu_region
}

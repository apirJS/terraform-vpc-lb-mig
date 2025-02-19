

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
  source                      = "./modules/compute"
  myvpc_id                    = module.network.myvpc_id
  subnet_eu_id                = module.network.subnet_eu_id
  subnet_asia_id              = module.network.subnet_asia_id
  instance_group_asia_region  = var.instance_group_asia_region
  instance_group_eu_region    = var.instance_group_eu_region
  instance_startup_script_url = var.instance_startup_script_url
}

module "iam" {
  source        = "./modules/iam"
  project_id    = var.project_id
  auditors      = var.auditors
  auditor_roles = var.auditor_roles
}


module "suite" {
  source                   = "./modules/suite"
  dashboard_display_name   = var.dashboard_display_name
  instance_group_asia_name = module.compute.instance_group_asia_name
  instance_group_eu_name   = module.compute.instance_group_eu_name
}

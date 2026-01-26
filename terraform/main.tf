module "vpc" {
  source       = "./modules/vpc"
  az_count     = var.az_count
  my_vpc_cidr  = var.my_vpc_cidr
  app_port     = var.app_port
  project_name = var.project_name
}

module "alb" {
  source            = "./modules/alb"
  public_subnets    = module.vpc.public_subnet_ids
  alb_sg            = module.vpc.alb_sg_id
  vpc_id            = module.vpc.vpc_id
  certificate_arn   = module.acm.certificate_arn
  health_check_path = var.health_check_path
}

module "ecs" {
  source            = "./modules/ecs"
  ecs_subnets       = module.vpc.private_subnet_ids
  ecs_sg            = module.vpc.ecs-task-sg
  alb_tg            = module.alb.target_group_arn
  aws_region        = var.aws_region
  app_port          = var.app_port
  region_count      = var.az_count
  project_name      = var.project_name
  health_check_path = var.health_check_path
  app_count         = var.app_count
  app_image         = var.app_image
}

module "acm" {
  source            = "./modules/acm"
  zone_id           = module.Route53.zone_id
  project_name      = var.project_name
  validation_method = var.validation_method
  domain_name       = var.domain_name
  subdomain         = var.subdomain
}

module "Route53" {
  source      = "./modules/Route53"
  alb_dns     = module.alb.alb_hostname
  alb_zone    = module.alb.alb_zone_id
  subdomain   = var.subdomain
  domain_name = var.domain_name
}




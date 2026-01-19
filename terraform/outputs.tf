output "public_subnets" {
  value = module.vpc.public_subnet_ids

}

output "private_subnets" {
  value = module.vpc.private_subnet_ids

}

output "aws_region" {
  value = var.aws_region

}

output "alb_dns" {
  description = "This is the alb dns"
  value       = module.alb.alb_hostname
}

output "app_dns" {
  value = var.domain_name
}
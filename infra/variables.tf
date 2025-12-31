variable "aws_region" {
 description = "Choose desired AWS Region in which the Ressources will be built"
}

variable "az_count" {
    description = "Set the desired Count (will decide the amount of Subnets)"
  
}
 
variable "my_vpc_cidr" {
    description = "Enter the desired VPC CIDR block"
  
}


variable "app_port" {
    description = "Enter the Container Port"
 
}

variable "project_name" {
    description = "Choose Project name, which ressources are gonne be named after"
  
}


variable "health_check_path" {
  
}

variable "fargate_cpu" {
    description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
    
}


variable "fargate_memory" {
    description = "Fargate instance memory to provision (in MiB)"
    
}

variable "domain_name" {
description = "Domain name for the App"
  

}
variable "validation_method" {
}  

variable "hosted_zone" {
  
}

variable "cert_domain" {
  
}
variable "subdomain" {
  
}
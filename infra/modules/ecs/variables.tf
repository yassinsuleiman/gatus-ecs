

variable "aws_region" {
    description = "The AWS region things are created in"
}

variable "ec2_task_execution_role_name" {
    description = "ECS task execution role name"
    default = "myEcsTaskExecutionRole"
}


variable "region_count" {
    description = "Number of AZs to cover in a given region"
    
}

variable "app_image" {
    description = "Docker image to run in the ECS cluster"
    default = "bradfordhamilton/crystal_blockchain:latest"
}



variable "app_count" {
    description = "Number of docker containers to run"
    default = 3
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
    description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
    default = "1024"
}

variable "fargate_memory" {
    description = "Fargate instance memory to provision (in MiB)"
    default = "2048"
}

variable "app_port" {
    
}

variable "ecs_subnets" {
    description = " Subnets in which the ECS is deployed"
    
}

variable "ecs_sg" {
    description = "Security group for the ECS"
    
}
variable "alb_tg" {
  
}



variable "project_name" {
  
}

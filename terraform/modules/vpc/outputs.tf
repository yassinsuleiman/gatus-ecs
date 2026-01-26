output "vpc_id" {
  value = aws_vpc.gatus_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of all public subnets"
  value       = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  description = "IDs of all private subnets"
  value       = aws_subnet.private.*.id
}

output "ecs-task-sg" {
  value = aws_security_group.ecs_tasks_sg.id
}
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "app_port" {
  value = var.app_port

}



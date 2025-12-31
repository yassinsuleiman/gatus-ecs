output "health_check_path" {
value = var.health_check_path
  
}

output "alb_hostname" {
  description = "This is the ALB DNSS"
  value = aws_alb.main.dns_name
}

output "alb_tg" {
  description = "ID of the Load balancer Target Group"
  value = aws_alb_target_group.app_tg.id
}

output "lb_listener" {
  value = aws_alb_target_group.app_tg
}

output "target_group_arn" {
  value = aws_alb_target_group.app_tg.arn
}

output "listener_http" {
  value = aws_alb_listener.http
}


output "alb_zone_id" {
  value       = aws_alb.main.zone_id
  description = "Canonical hosted zone id for the ALB (used in Route53 alias records)"
}
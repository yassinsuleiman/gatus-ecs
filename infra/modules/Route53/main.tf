#Hosted Zone
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}


resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = var.alb_dns
    zone_id                = var.alb_zone
    evaluate_target_health = true
  }
}
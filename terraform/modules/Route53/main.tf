#Hosted Zone
resource "aws_route53_zone" "primary" {
  name = var.domain_name


}

#Copy NS of Registered domain to Hosted zone for ACM Validation 

resource "aws_route53domains_registered_domain" "domain" {
  domain_name = var.domain_name

  dynamic "name_server" {
    for_each = aws_route53_zone.primary.name_servers
    content {
      name = name_server.value

    }
  }

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
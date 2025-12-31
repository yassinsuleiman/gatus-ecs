data "aws_acm_certificate" "cert" {
  domain      = var.cert_domain
  statuses    = ["ISSUED"]
  most_recent = true
}
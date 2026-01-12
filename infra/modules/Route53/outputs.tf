output "zone_id" {
  value = aws_route53_zone.primary.zone_id
}

# output "name_servers" {
#   value = aws_route53_zone.main.name_servers
# }

# output "zone_name" {
#   value = aws_route53_zone.main.arn
# }

# output "fqdn" {
#   value = aws_route53_record.app.fqdn
#}
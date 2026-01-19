output "certificate_arn" {
  value       = aws_acm_certificate.cert.arn
  description = "ACM ARN that is needed for the HTTPS listener"
}

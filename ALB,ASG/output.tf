output "alb_public_url" {
  description = "Public URL"
  value       = aws_lb.sujata-alb.dns_name
}
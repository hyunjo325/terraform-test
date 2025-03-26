output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}
output "listener_arn" {
  value = aws_lb_listener.http.arn
}
output "zone_id" {
  value = aws_lb.this.zone_id
}
output "alb_arn" {
  value = aws_lb.this.arn
}


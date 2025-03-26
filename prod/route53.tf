data "aws_route53_zone" "main" {
  name = "evanevan.click"
}
resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "evanevan.click"
  type    = "A"

  alias {
    name                   = module.prod_alb.alb_dns_name
    zone_id                = module.prod_alb.zone_id
    evaluate_target_health = true
  }
}

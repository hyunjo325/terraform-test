resource "aws_wafv2_web_acl" "prod_waf" {
  name        = "prod-waf"
  scope       = "REGIONAL"
  description = "WAF for prod ALB"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit-ip"
    priority = 1
    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rateLimit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "prodWaf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "prod-waf"
  }
}

resource "aws_wafv2_web_acl_association" "prod_alb_waf" {
  resource_arn = module.prod_alb.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.prod_waf.arn
}


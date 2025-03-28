variable "sns_topic_name" {
  type    = string
  default = "alarm-topic"
}
variable "slack_webhook_url" {
  description = "Slack Webhook URL"
  type        = string
}

variable "name" {
  type        = string
  description = "Prefix for resource names"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB is deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for the ALB"
}

variable "target_port" {
  type        = number
  description = "Port for the Target Group (usually 80 or container port)"
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for HTTPS"
  type        = string
}


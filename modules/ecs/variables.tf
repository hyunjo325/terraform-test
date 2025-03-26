variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "family" {
  type        = string
  description = "Task definition family name"
}

variable "service_name" {
  type        = string
  description = "Name of the ECS service"
}

variable "container_name" {
  type        = string
  description = "Name of the container"
}

variable "image" {
  type        = string
  description = "Docker image URL"
}

variable "cpu" {
  type        = string
  description = "CPU units for the task"
}

variable "memory" {
  type        = string
  description = "Memory (MiB) for the task"
}

variable "container_port" {
  type        = number
  description = "Container port to expose"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "security_group_id" {
  type        = string
  description = "Security group for ECS task"
}

variable "execution_role_arn" {
  type        = string
  description = "IAM Role ARN for ECS execution"
}

variable "target_group_arn" {
  type        = string
  description = "Target group ARN for ALB"
}

variable "lb_listener_arn" {
  type        = string
  description = "ALB listener ARN (used for dependency)"
}


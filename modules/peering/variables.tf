variable "name" {
  description = "Name prefix for the peering connection"
  type        = string
}

variable "vpc_id" {
  description = "Requester VPC ID"
  type        = string
}

variable "peer_vpc_id" {
  description = "Accepter VPC ID"
  type        = string
}


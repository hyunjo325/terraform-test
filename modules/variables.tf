variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "peer_vpc_id" {
  type = string
}

variable "peer_region" {
  type    = string
  default = "ap-northeast-2"
}


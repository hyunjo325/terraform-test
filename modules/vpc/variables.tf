# modules/vpc/variables.tf
variable "name" {
  description = "Name prefix"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability Zones to use"
  type        = list(string)
}

variable "route_table_ids" {
  type    = list(string)
  default = []
}
variable "peering_connection_id" {
  description = "Peering connection ID for route table update"
  type        = string
  default     = null
}

variable "peer_cidr_block" {
  description = "CIDR block of the peer VPC"
  type        = string
  default     = null
}

variable "route_table_ids_to_update" {
  description = "Route table IDs to add peering route to"
  type        = list(string)
  default     = []
}


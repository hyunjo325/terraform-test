resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.vpc_id
  peer_vpc_id   = var.peer_vpc_id
  auto_accept   = true

  tags = {
    Name = "${var.name}-peering"
  }
}


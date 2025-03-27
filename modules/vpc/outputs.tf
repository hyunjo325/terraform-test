output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
output "public_route_table_ids" {
  value = [aws_route_table.public.id]
}

output "ecs_private_subnet_ids" {
  value = aws_subnet.ecs_private[*].id
}

output "db_private_subnet_ids" {
  value = aws_subnet.db_private[*].id
}

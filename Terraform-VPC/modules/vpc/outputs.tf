output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.subnets[*].id
}

output "route_table_id" {
  value = aws_route_table.rt.id
}
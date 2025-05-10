output "my_vpc_id" {
  value = aws_vpc.network_vpc.id
}

output "my_internet_gateway_id"  {
  value = aws_internet_gateway.network_vpc_gateway.id
}

output "my_vpc_cidr" {
  value = aws_vpc.network_vpc.cidr_block
}
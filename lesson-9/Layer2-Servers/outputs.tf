output "my_sec_group" {
    value = aws_security_group.web_sg.id
}

output "my_aws_subnet" {
    value = aws_subnet.main.id
}

output "my_ec2_instance" {
  value = aws_instance.my_webserver.id
}


# OUTPUTS FROM LAYER1-NETWORK
output "REMOTE_DATA_NETWORK_LAYER_my_internet_gateway_id"  {
  value = local.vpc_cidr
}

output "REMOTE_DATA_NETWORK_LAYER_my_vpc_cidr" {
  value = local.internet_gateway
}


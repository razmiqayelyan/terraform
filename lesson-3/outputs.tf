output "webserver_instance_id" {
  description = "ID of the EC2 web server instance"
  value       = aws_instance.my_webserver.id
}

output "webserver_public_ip_address" {
  description = "Public IP address of the EC2 instance (Elastic IP)"
  value       = aws_eip.my_static_ip.public_ip
}

output "webserver_sg_id" {
  description = "Security Group ID assigned to the web server"
  value       = aws_security_group.my_webserver.id
}

output "webserver_sg_arn" {
  description = "ARN of the security group used by the web server"
  value       = aws_security_group.my_webserver.arn
}

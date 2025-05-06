output "elb_dns_name" {
  value = aws_elb.classic_lb.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.web_asg.name
}

output "how_to_run_terraform" {
    value = [ "terraform apply -var-file=dev.tfvars", "terraform apply -var-file=prod.tfvars" ]
}
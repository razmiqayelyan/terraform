common_tags = {
  Environment = "prod"
  Owner       = "razmik"
  Project     = "my-web-stack"
}
asg_desired_capacity = 4
asg_min_size         = 4
asg_max_size         = 8
elb_name             = "prod-classic-lb"

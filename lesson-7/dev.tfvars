common_tags = {
  Environment = "dev"
  Owner       = "razmik"
  Project     = "my-web-stack"
}
asg_desired_capacity = 2
asg_min_size         = 2
asg_max_size         = 4
elb_name             = "dev-classic-lb"

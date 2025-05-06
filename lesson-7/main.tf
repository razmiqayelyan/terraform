locals {
  user_data_hash = filesha256("user_data.sh")
  az1_name       = data.aws_availability_zones.available.names[0]
  az2_name       = data.aws_availability_zones.available.names[1]
}

# --------------------- SECURITY GROUP ---------------------
data "aws_security_group" "my_webserver" {
  filter {
    name   = "group-name"
    values = ["sec_group_by_terraform"]
  }

  vpc_id = data.aws_vpc.default.id
}

# --------------------- LAUNCH TEMPLATE ---------------------
resource "aws_launch_template" "web_template" {
  name_prefix   = "web-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = filebase64("user_data.sh")

  vpc_security_group_ids = [data.aws_security_group.my_webserver.id]

tag_specifications {
  resource_type = "instance"
  tags = merge(
    var.common_tags,
    {
      Name         = "${var.project_name}-${var.common_tags["Environment"]}"
      UserDataHash = local.user_data_hash
    }
  )
}

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------- LOAD BALANCER ---------------------
resource "aws_elb" "classic_lb" {
  name               = var.elb_name
  subnets            = [data.aws_subnet.subnet_az1.id, data.aws_subnet.subnet_az2.id]
  security_groups    = [data.aws_security_group.my_webserver.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  cross_zone_load_balancing       = true
  idle_timeout                    = 60
  connection_draining             = true
  connection_draining_timeout     = 60

tags = merge(
  var.common_tags,
  {
    Name = "${var.elb_name}-${var.common_tags["Environment"]}"
  }
)

}

# --------------------- AUTO SCALING GROUP ---------------------
resource "aws_autoscaling_group" "web_asg" {
  name_prefix      = "web-asg-"
  desired_capacity = var.asg_desired_capacity
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size

  vpc_zone_identifier = [
    data.aws_subnet.subnet_az1.id,
    data.aws_subnet.subnet_az2.id
  ]

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }

  tag {
    key                 = "UserData-Hash"
    value               = local.user_data_hash
    propagate_at_launch = false
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------- ATTACH ASG TO CLASSIC LB ---------------------
resource "aws_autoscaling_attachment" "asg_elb" {
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  elb                    = aws_elb.classic_lb.name
}

# --------------------- AZs & Subnets ---------------------
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "subnet_az1" {
  availability_zone = local.az1_name
  vpc_id            = data.aws_vpc.default.id
}

data "aws_subnet" "subnet_az2" {
  availability_zone = local.az2_name
  vpc_id            = data.aws_vpc.default.id
}

# --------------------- DEFAULT VPC ---------------------
data "aws_vpc" "default" {
  default = true
}

# --------------------- LATEST AMAZON LINUX ---------------------
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

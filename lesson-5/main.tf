# HTTPD WEB APP FROM TERRAFORM ( USER DATA )
# --- Security Group ---
# Name: global-access-security-group
# ID: sg-0a78a063c41e67482

# --- Amazon Linux 2023 ---
# AMI x86: ami-0e449927258d45bc4
# AMI ARM: ami-086a54924e40cab98

# --- Ubuntu 24.04 LTS ---
# AMI x86: ami-084568db4383264d4
# AMI ARM: ami-0c4e709339fa8521a

# --- Common Instance Types ---
# t2.micro     # x86, Free tier
# t3.micro     # x86, burstable
# t4g.micro    # ARM, Free tier
# m6g.medium   # ARM, general purpose
# c7g.medium   # ARM, compute optimized
# m5.large     # x86, general purpose




#--------------------- AVAILABILITY ZONES -----------------

# Step 1: Get all available AZs in current region
data "aws_availability_zones" "available" {
  state = "available"
}
# Step 2: Create locals for individual AZ names
locals {
  user_data_hash = filesha256("user_data.sh") 
  az1_name = data.aws_availability_zones.available.names[0]
  az2_name = data.aws_availability_zones.available.names[1]
}
# Step 3: Reference each AZ individually (if needed)
data "aws_availability_zone" "az1" {
  name = local.az1_name
}
data "aws_availability_zone" "az2" {
  name = local.az2_name
}






#--------------------- SECURITY GROUP -----------------
resource "aws_security_group" "my_webserver" {
  name = "sec_group_by_terraform"
  description = "My Security Group Created by Terraform .tf File"


  #inblound rules 80 & 443 ( HTTP+HTTPS )
  dynamic "ingress" {
    for_each = ["80", "443", "22", "8080"]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    }
  }
  #outbound rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}


#--------------------- LAUNCH CONFIGURATION -----------------
resource "aws_launch_template" "web_template" {
  name_prefix   = "web-template-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  user_data = filebase64("user_data.sh")
  lifecycle {
    create_before_destroy = true
   }

  vpc_security_group_ids = [aws_security_group.my_webserver.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name          = "web-asg-instance"
      UserDataHash  = local.user_data_hash
    }
  }
}

#--------------------- AUTO SCALING GROUP -----------------
resource "aws_autoscaling_group" "web_asg" {
  name_prefix          = "web-asg-"
  max_size             = 4
  min_size             = 2
  desired_capacity     = 2


  vpc_zone_identifier = [
    data.aws_subnet.subnet_az1.id,
    data.aws_subnet.subnet_az2.id
  ]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }

   tag {
    key                 = "UserData-Hash"
    value               = local.user_data_hash
    propagate_at_launch = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------- CONNECT ELASTIC LOAD BALANCER & AUTO SCALING GROUP -----------------
resource "aws_autoscaling_attachment" "asg_elb" {
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  elb                    = aws_elb.classic_lb.name
}

#--------------------- ELASTIC LOAD BALANCER -----------------
resource "aws_elb" "classic_lb" {
  name               = "my-classic-lb"
  subnets = [
    data.aws_subnet.subnet_az1.id,
    data.aws_subnet.subnet_az2.id
  ]
  security_groups    = [aws_security_group.my_webserver.id]

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

  cross_zone_load_balancing = true
  idle_timeout              = 60
  connection_draining       = true
  connection_draining_timeout = 60

  tags = {
    Name = "Classic-LB"
  }
}

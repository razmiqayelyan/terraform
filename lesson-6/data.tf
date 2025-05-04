#--------------------- DEFAULT VPC -----------------
data "aws_vpc" "default" {
  default = true
}

#--------------------- AMAZON-LINUX AMI -----------------
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

# --------------------- SECURITY GROUP ---------------------
data "aws_security_group" "my_webserver" {
  id = "sg-0a78a063c41e67482"
}


# --------------------- PROVIDER & VARIABLE ---------------------
variable "active_color" {
  description = "Which environment (green or blue) should receive traffic?"
  default     = "green"
}


#--------------------- AVAILABILITY ZONES -----------------
data "aws_availability_zones" "available" {
  state = "available"
}

#--------------------- DEFAULT SUBNETS (AUTO-FETCH) -----------------
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "subnet_az1" {
  availability_zone = local.az1_name
  vpc_id            = data.aws_vpc.default.id
}

data "aws_subnet" "subnet_az2" {
  availability_zone = local.az2_name
  vpc_id            = data.aws_vpc.default.id
}

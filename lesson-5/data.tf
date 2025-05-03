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

#--------------------- DEFAULT SUBNETS (AUTO-FETCH) -----------------
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "subnet_az1" {
  id = data.aws_subnets.default.ids[0]
}

data "aws_subnet" "subnet_az2" {
  id = data.aws_subnets.default.ids[1]
}
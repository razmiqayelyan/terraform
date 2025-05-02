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


# Get the latest Ubuntu 18.04 AMI from Canonical
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (official Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}


# Get the latest Amazon-Linux AMI from Canonical
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

data "aws_region" "current" {}


# ----------- DEPENDS ON - RUN / START SERVERS BY SPECIFYING QUEUE -------------
# resource "aws_instance" "my_server_db" {
#   ami                    = "ami-084568db4383264d4"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = ["sg-0a78a063c41e67482"]
  
#   tags = {
#     Name = "Server-Database"
#   }
# }

# resource "aws_instance" "my_server_app" {
#   ami                    = "ami-084568db4383264d4"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = ["sg-0a78a063c41e67482"]

#   tags = {
#     Name = "Server-Application"
#   }

#   depends_on = [aws_instance.my_server_db]
# }

# resource "aws_instance" "my_server_web" {
#   ami                    = "ami-084568db4383264d4"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = ["sg-0a78a063c41e67482"]


#   tags = {
#     Name = "Server-Web"
#   }

#   depends_on = [aws_instance.my_server_db]
# }

# Output the latest UBUNTU AMI ID
output "latest_ubuntu_ami_id" {
  description = "The latest Ubuntu 18.04 AMI ID"
  value       = data.aws_ami.latest_ubuntu.id
}


# Output the latest UBUNTU AMI name
output "latest_ubuntu_ami_name" {
  description = "The latest Ubuntu 18.04 AMI name"
  value       = data.aws_ami.latest_ubuntu.name
}


# Output the latest AMAZON-LINUX AMI ID
output "latest_amazon_linx_ami_id" {
  description = "The latest Ubuntu 18.04 AMI ID"
  value       = data.aws_ami.latest_amazon_linux.id
}


# Output the latest AMAZON-LINUX AMI name
output "latest_amazon_linux_ami_name" {
  description = "The latest Ubuntu 18.04 AMI name"
  value       = data.aws_ami.latest_amazon_linux.name
}


# Output current Region name
output "current_aws_region" {
  description = "The AWS region currently in use"
  value       = data.aws_region.current.name
}
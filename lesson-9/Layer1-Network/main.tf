# Configure remote state storage in an S3 bucket
terraform {
  backend "s3" {
    bucket = "terraform-state-razmiqayelyan"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}

# Define the CIDR block for the VPC
variable "vpc_cide" {
  default = "10.0.0.0/16"
}

# Create a VPC for the network
resource "aws_vpc" "network_vpc" {
  cidr_block = var.vpc_cide
  tags = {
    Name : "Network VPC"
  }
}

# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "network_vpc_gateway" {
  vpc_id = aws_vpc.network_vpc.id
}

provider "aws" {
  region = "us-east-1"
}


module "vpc-prod" {
  source               = "../modules/aws_network"
  env                  = "prod"
  vpc_cidr             = "10.100.0.0/16"
  public_cidr_subnets  = ["10.100.1.0/24", "10.100.2.0/24"]
  private_subnet_cidrs = ["10.100.11.0/24", "10.100.12.0/24"]
}

module "vpc-dev" {
  source               = "../modules/aws_network"
  env                  = "dev"
  vpc_cidr             = "10.200.0.0/16"
  public_cidr_subnets  = ["10.200.1.0/24", "10.200.2.0/24"]
  private_subnet_cidrs = ["10.200.11.0/24", "10.200.12.0/24"]
}
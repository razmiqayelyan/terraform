# Configure remote state storage in an S3 bucket
terraform {
    backend "s3" {
      bucket = "terraform-state-razmiqayelyan"
      key = "dev/servers/terraform.tfstate"
      region = "us-east-1"
    }
}



# ✅ Load outputs from the remote Terraform state file (for networking info)
data "terraform_remote_state" "network" {
  backend = "s3"
  config =  {
    bucket = "terraform-state-razmiqayelyan"
    key = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}


# ✅ Create a security group in the VPC referenced from the remote state
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.terraform_remote_state.network.outputs.my_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebSecurityGroup"
  }
}





# ✅ Create a subnet in the same VPC from remote state
resource "aws_subnet" "main" {
  vpc_id                  = data.terraform_remote_state.network.outputs.my_vpc_id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

locals  {
    vpc_cidr = data.terraform_remote_state.network.outputs.my_vpc_cidr
    internet_gateway = data.terraform_remote_state.network.outputs.my_internet_gateway_id
}


# ✅ Launch an EC2 instance into the subnet and VPC using the new SG
resource "aws_instance" "my_webserver" {
  subnet_id     = aws_subnet.main.id
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    Name = "MyTerraformUbuntu"
    VPC_CIDR = local.vpc_cidr
    INTERNET_GATEWAY = local.internet_gateway
  key_name = "us-east-1"
}
}
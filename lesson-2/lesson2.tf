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

resource "aws_instance" "my_webserver" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "sg-0a78a063c41e67482" ]
  tags = {
    Name = "MyTerraformUbuntu"
  }
  key_name = "us-east-1"
# USE FILE FOR STATIC CONTENT
#  user_data = file("user_data.sh")

# USE TEMPLATEFILE IF YOU NEED TO USE SOMEDYNAMIC DATA INSIDE OF YOUR TAMPLATE ( file need to be ended with .tpl)
  user_data = templatefile("user_data.sh.tpl", {
    my_name = "Razo"
    last_initial = "M."
    visited_cities = ["LA", "NYC", "Miami", "San Diego", "SF", "Chicago", "Las Vegas"]
  })

}

resource "aws_security_group" "my_webserver" {
  name = "sec_group_by_terraform"
  description = "My Security Group Created by Terraform .tf File"


  #inblound rules 80 & 443 ( HTTP+HTTPS )
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  #outbound rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}
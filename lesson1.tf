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



provider "aws" {
    access_key = "YOUR_AWS_PUBLIC_KEY"
    secret_key = "YOUR_AWS_SECRET_KEY"
    region = "us-east-1"
}

resurce "aws_instance" "my_ubuntu" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"

}
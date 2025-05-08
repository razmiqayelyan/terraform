resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "python3 -c \"print('Hello World!')\""
  }
}


resource "null_resource" "command2" {
  provisioner "local-exec" {
    command     = "print ( 'Hello World!' )"
    interpreter = ["python3", "-c"]
  }
}

resource "null_resource" "command3" {
  provisioner "local-exec" {
    command = "echo $NAME1 $NAME2 $NAME3 >> names.txt"
    environment = {
      NAME1 = "Vasya"
      NAME2 = "Petya"
      NAME3 = "Kolya"
    }
  }
}

# resource "aws_instance" "myserver" {
#   ami           = "ami-0e449927258d45bc4"
#   instance_type = "t2.micro"

#   provisioner "local-exec" {
#     command = "echo Hello from AWS Instance Creation!"
#   }
# }



# GENERATE PASSWORD AND SAVE IN SSM PARAMETER STORE
resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "!#$&"
}

resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/mysql"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
}

# GET RECENTLY CREATED PASSWORD FROM SSM PARAMETER STORE
data "aws_ssm_parameter" "my_rds_password" {
  name        = "/prod/mysql"
  depends_on  = [aws_ssm_parameter.rds_password]
  with_decryption = true
}



locals  {
  pass_for_mysql = data.aws_ssm_parameter.my_rds_password.value
}


output "rds_password" {
  value =local.pass_for_mysql
  sensitive = true
}




# CREATE SIMPLE MYSQL DB TO SETUP WITH RECENTLY GENERATED PASSWORD
# resource "aws_db_instance" "default" {
#   identifier              = "prod-rds"
#   allocated_storage       = 20
#   storage_type            = "gp2"
#   engine                  = "mysql"
#   engine_version          = "8.0.35"
#   instance_class          = "db.t3.micro"
#   db_name                 = "prod"
#   username                = "administrator"
#   password                = local.pass_for_mysql
#   parameter_group_name    = "default.mysql8.0"  # ✅ Updated for MySQL 8.0
#   skip_final_snapshot     = true
#   apply_immediately       = true
# }



# TERRAFORM CONDITIONS | IF , ELSE
# variable "env" {
#   default = "staging"
# }

# resource "aws_instance" "MyAmazonLinux" {
#   count = var.env == "prod"? 1 : 2 # Also you can do Count = 0 ex: you dont wont to run instance with prod env
#   ami = "ami-0e449927258d45bc4"
#   vpc_security_group_ids      = ["sg-0a78a063c41e67482"]
#   associate_public_ip_address = true
#   instance_type = var.env == "prod"? "t2.micro" : "t2.small"
#   tags = {
#     "Name" = "MyAmazonLinuxEC2"
#   }
# }


# TERRAFORM LOOKUP | lookup()
variable "env" {
  default = "staging"
}

variable "ec2_size" {
  default = {
    "prod": "t2.micro"
    "dev": "t2.small"
    "staging":"t3.micro"
  }
}

resource "aws_instance" "MyAmazonLinux" {
  count = var.env == "prod"? 2 : 1 # Also you can do Count = 0 ex: you dont wont to run instance with prod env
  ami = "ami-0e449927258d45bc4"
  vpc_security_group_ids      = ["sg-0a78a063c41e67482"]
  associate_public_ip_address = true
  instance_type =lookup(var.ec2_size, var.env)
  tags = {
    "Name" = "MyAmazonLinuxEC2"
  }
}


# LENGHT() + ELEMENT() -> BULK CHANGE
variable "aws_users" {
  description = "AWS Users need to be created in IAM"
  default = ["Razo", "Ozar", "Zoar", "Arzo", "Roza", "Zaro", "Raz"]
}

resource "aws_iam_user" "users" {
  count = length(var.aws_users)
  name = element(var.aws_users, count.index)
}


# MULTI REGION SETUP AWS
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "ca-central-1"
  alias = "CANADA"
}

provider "aws" {
  region = "eu-west-2"
  alias = "LONDON"
}


# find latest ami in each region
data "aws_ami" "canada_latest_ubuntu" {
  provider    = aws.CANADA
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu) official AMI owner

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_ami" "default_latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu) official AMI owner

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_ami" "london_latest_ubuntu" {
  provider    = aws.LONDON
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu) official AMI owner

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

# create 3 instances in each region
resource "aws_instance" "default_ec2" {
  instance_type = "t2.micro"
  ami = data.aws_ami.default_latest_ubuntu.id
  tags = {
    Name: "Default"
  }
}

resource "aws_instance" "canada_ec2" {
  provider = aws.CANADA
  instance_type = "t2.micro"
  ami = data.aws_ami.canada_latest_ubuntu.id
  tags = {
    Name: "CANADA"
  }
}

resource "aws_instance" "london_ec2" {
  provider = aws.LONDON
  instance_type = "t2.micro"
  ami = data.aws_ami.london_latest_ubuntu.id
  tags = {
    Name: "LONDON"
  }
}
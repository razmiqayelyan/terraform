# --- ENVIRONMENT SELECTION (for blue/green deployments) ---
variable "active_color" {
  description = "Set the active environment for deployment. Options: blue, green"
  type        = string
  default     = "blue"
}

# --- INSTANCE CONFIGURATION ---
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Amazon Machine Image ID for EC2 instance"
  type        = string
  default     = "ami-0e449927258d45bc4" # Amazon Linux 2023 (x86)
}

# --- AUTO SCALING CONFIGURATION ---
variable "asg_min_size" {
  description = "Minimum number of EC2 instances in ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in ASG"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in ASG"
  type        = number
  default     = 2
}

# --- LOAD BALANCER CONFIGURATION ---
variable "elb_name" {
  description = "Name of the Classic Load Balancer"
  type        = string
  default     = "my-classic-lb"
}

# --- SECURITY GROUP RULES ---
variable "allowed_ports" {
  description = "List of allowed ingress ports"
  type        = list(number)
  default     = [80, 443, 22, 8080]
}

# --- TAGGING ---
variable "project_name" {
  description = "Name tag for resources"
  type        = string
  default     = "web-asg-instance"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  # default = {
  #   Environment = "dev"
  #   Owner       = "yourname"
  #   Project     = "webapp"
  # }
  default = {
    Name = "MyEC2Instance"
    Environment = "no-env"

  }
}

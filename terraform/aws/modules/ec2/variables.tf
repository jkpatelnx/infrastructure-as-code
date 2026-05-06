variable "ec2_instance_name" {
  description = "This variable holds EC2 instance name"
  default = "terra-automate-server"
  type = string
}
variable "ec2_volume_size" {
  description = "This variable holds EC2 instance volume size"
  default = 10
  type = number
}
variable "ec2_instance_state" {
  description = "This variable holds EC2 instance state"
  default = "running"
  type = string
}
variable "ec2_ami_id" {
  description = "This variable holds EC2 ami id"
  default = "ami-091138d0f0d41ff90"
  type = string
}
variable "ec2_instance_type" {
  description = "This variable holds EC2 instance type"
  default = "t2.micro" # 16 vCPU account limit
  type = string
}
variable "ec2_instance_count" {
  description = "This variable holds EC2 instance count"
  default = 1
  type = number
}

variable "env" {
  description = "This variable holds the environment"
  default     = "dev"
  type        = string
}

variable "name_suffix" {
  description = "Unique suffix per module call to avoid resource name conflicts (e.g. pub-az1, prv-az2)"
  type        = string
  default     = "default"
}

variable "subnet_id" {
  description = "Subnet ID where EC2 instances will be launched (custom VPC public subnet AZ[0])"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group (custom VPC)"
  type        = string
}


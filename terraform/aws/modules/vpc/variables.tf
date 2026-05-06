variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
  default     = "my_vpc"
}

variable "internet_gateway_name" {
  type        = string
  description = "Name tag for the internet gateway"
  default     = "my_igw"
}

variable "public_subnet_1_cidr_block" {
  type        = string
  description = "CIDR block for public subnet 1"
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr_block" {
  type        = string
  description = "CIDR block for public subnet 2"
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr_block" {
  type        = string
  description = "CIDR block for private subnet 1"
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr_block" {
  type        = string
  description = "CIDR block for private subnet 2"
  default     = "10.0.4.0/24"
}

variable "public_subnet_1_az_index" {
  type        = number
  description = "AZ index for public subnet 1"
  default     = 0
}

variable "public_subnet_2_az_index" {
  type        = number
  description = "AZ index for public subnet 2"
  default     = 1
}

variable "private_subnet_1_az_index" {
  type        = number
  description = "AZ index for private subnet 1"
  default     = 0
}

variable "private_subnet_2_az_index" {
  type        = number
  description = "AZ index for private subnet 2"
  default     = 1
}

variable "public_subnet_1_name" {
  type        = string
  description = "Name tag for public subnet 1"
  default     = "my_public_subnet_1"
}

variable "public_subnet_2_name" {
  type        = string
  description = "Name tag for public subnet 2"
  default     = "my_public_subnet_2"
}

variable "private_subnet_1_name" {
  type        = string
  description = "Name tag for private subnet 1"
  default     = "my_private_subnet_1"
}

variable "private_subnet_2_name" {
  type        = string
  description = "Name tag for private subnet 2"
  default     = "my_private_subnet_2"
}

variable "nat_eip_1_name" {
  type        = string
  description = "Name tag for NAT EIP 1"
  default     = "nat_eip_1"
}

variable "nat_eip_2_name" {
  type        = string
  description = "Name tag for NAT EIP 2"
  default     = "nat_eip_2"
}

variable "nat_gateway_1_name" {
  type        = string
  description = "Name tag for NAT gateway 1"
  default     = "my_nat_1"
}

variable "nat_gateway_2_name" {
  type        = string
  description = "Name tag for NAT gateway 2"
  default     = "my_nat_2"
}

variable "public_route_table_name" {
  type        = string
  description = "Name tag for the shared public route table"
  default     = "my_shared_public_route_table1"
}

variable "private_route_table_1_name" {
  type        = string
  description = "Name tag for private route table 1"
  default     = "my_private_route_table1"
}

variable "private_route_table_2_name" {
  type        = string
  description = "Name tag for private route table 2"
  default     = "my_private_route_table2"
}

#####################################################
# VPC Outputs
#####################################################

output "vpc_id" {
  description = "VPC ID from the vpc module"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs from the vpc module"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs from the vpc module"
  value       = module.vpc.private_subnet_ids
}

#####################################################
# Public EC2 Instances — AZ[0]
#####################################################

output "aws_ec2_public_1_ips" {
  description = "Public IPs — public subnet AZ[0]"
  value       = module.ec2_public_1.aws_ec2_instance_ip
}

output "aws_ec2_public_1_private_ips" {
  description = "Private IPs — public subnet AZ[0]"
  value       = module.ec2_public_1.aws_ec2_instance_private_ip
}

#####################################################
# Public EC2 Instances — AZ[1]
#####################################################

output "aws_ec2_public_2_ips" {
  description = "Public IPs — public subnet AZ[1]"
  value       = module.ec2_public_2.aws_ec2_instance_ip
}

output "aws_ec2_public_2_private_ips" {
  description = "Private IPs — public subnet AZ[1]"
  value       = module.ec2_public_2.aws_ec2_instance_private_ip
}

#####################################################
# Private EC2 Instances — AZ[0]
#####################################################

output "aws_ec2_private_1_ips" {
  description = "Private IPs — private subnet AZ[0]"
  value       = module.ec2_private_1.aws_ec2_instance_private_ip
}

#####################################################
# Private EC2 Instances — AZ[1]
#####################################################

output "aws_ec2_private_2_ips" {
  description = "Private IPs — private subnet AZ[1]"
  value       = module.ec2_private_2.aws_ec2_instance_private_ip
}


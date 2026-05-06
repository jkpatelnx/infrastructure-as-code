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

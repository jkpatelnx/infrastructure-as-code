output "aws_ec2_instance_ip" {
  description = "Public IP of each instance (empty string if in private subnet)"
  value       = aws_instance.my_instance[*].public_ip
}

output "aws_ec2_instance_private_ip" {
  description = "Private IP of each instance (always set)"
  value       = aws_instance.my_instance[*].private_ip
}

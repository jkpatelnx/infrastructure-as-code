output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.my_public_subnet_1.id,
    aws_subnet.my_public_subnet_2.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.my_private_subnet_1.id,
    aws_subnet.my_private_subnet_2.id
  ]
}
#################################################
# SSH Key
#################################################

resource "aws_key_pair" "deployer" {
  key_name   = "${var.env}-${var.name_suffix}-terra-automate-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

#################################################
# Security Group  (uses custom VPC via var.vpc_id)
#################################################

resource "aws_security_group" "my_security_group" {
  name        = "${var.env}-${var.name_suffix}-terra-security-group"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#################################################
# EC2 Instances
#################################################

resource "aws_instance" "my_instance" {
  count                  = var.ec2_instance_count
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = var.subnet_id                          # custom VPC public subnet AZ[0]
  vpc_security_group_ids = [aws_security_group.my_security_group.id]

  # root storage (EBS)
  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name        = "${var.env}-${var.ec2_instance_name}-${count.index + 1}"
    Environment = var.env
  }
}


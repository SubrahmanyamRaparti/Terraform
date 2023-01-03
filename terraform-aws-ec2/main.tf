resource "aws_instance" "aws_instance" {
  ami                    = var.ami == "" ? data.aws_ami.ami.id : var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  availability_zone      = var.availability_zone
  monitoring             = var.monitoring
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = {
    Name = var.name
  }
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

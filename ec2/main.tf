terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.21.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "aws_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.istest == true ? var.instance_type["test"] : var.instance_type["prod"]
  key_name      = aws_key_pair.terraform_key_pair.key_name
  # count = 1

  tags = local.common_tags
}

resource "aws_eip" "aws_server_ip" {
  vpc = true
  # instance = aws_instance.aws_server.id

  tags = local.common_tags
}

resource "aws_eip_association" "aws_eip_to_server_attach" {
  instance_id   = aws_instance.aws_server.id
  allocation_id = aws_eip.aws_server_ip.id
}

resource "aws_security_group" "sg" {
  name        = "terraform_SG"
  description = "Allow Developers to SSH"

  dynamic "ingress" {
    for_each = var.ingress_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      # cidr_blocks      = ["${aws_eip.aws_server_ip.public_ip}/32"]
    }
  }
  tags = local.common_tags
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.sg.id
  network_interface_id = aws_instance.aws_server.primary_network_interface_id
}

resource "aws_key_pair" "terraform_key_pair" {
  key_name   = "tf_key"
  public_key = file("/home/ubuntu/environment/sshkeys/terraform_key.pub")
}
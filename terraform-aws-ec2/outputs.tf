output "ami" {
  value = var.ami == "" ? data.aws_ami.ami.id : var.ami
}

output "public_ip" {
  value = resource.aws_instance.aws_instance.public_ip
}

output "public_dns" {
  value = resource.aws_instance.aws_instance.public_dns
}

output "private_ip" {
  value = resource.aws_instance.aws_instance.private_ip
}

output "private_dns" {
  value = resource.aws_instance.aws_instance.private_dns
}

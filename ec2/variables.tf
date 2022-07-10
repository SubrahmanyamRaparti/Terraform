variable "instance_type" {
  type = map(any)
  default = {
    test = "t2.micro"
    prod = "t2.large"
  }
}

# variable "ami" {
#     type = string
#     default = "ami-08df646e18b182346"       # ap-south-1
# }

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "deployment_region_name" {
  type = map(any)
  default = {
    test = "Development"
    prod = "Production"
  }
}

variable "ingress_ports" {
  description = "All inbound ports for a security group"
  type        = list(number)
  default     = [22, 80, 443, 8080, 4321]
}

variable "istest" {}
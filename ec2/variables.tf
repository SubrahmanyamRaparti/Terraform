variable "instance_type" {
    type = map
    default = {
        test = "t2.micro"
        prod = "t2.large"
    }
}

variable "ami" {
    type = string
    default = "ami-08df646e18b182346"       # ap-south-1
}

variable "region" {
    type = string
    default = "ap-south-1"
}

variable "deployment_region_name" {
    type = map
    default = {
        test = "Development"
        prod = "Production"
    }
}

variable "istest" {}
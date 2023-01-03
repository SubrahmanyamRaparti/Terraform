variable "ami" {
  description = "Amazon Machine Images (AMI)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Combinations of CPU, memory, storage, and networking capacity"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Availability zones"
  type        = string
  default     = null
}

variable "monitoring" {
  description = "EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

variable "vpc_security_group_ids" {
  description = "Security group ids"
  type        = list(string)
  default     = null
}

variable "name" {
  description = "Name of the instance"
  type        = string
  default     = null
}

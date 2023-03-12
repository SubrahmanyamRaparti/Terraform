variable "ecr_name" {
  description = "Name of the repository"
  type        = string
  default     = null
}

variable "ecr_tag_mutability" {
  description = "Tag immutability"
  type        = string
  default     = "IMMUTABLE"
}

variable "ecr_scan" {
  description = "Scan for vulnerabilities"
  type        = bool
  default     = true
}

#-------------------------------------------------------------------------------#
# VPC SECTION                                                                   #
#-------------------------------------------------------------------------------#

variable "vpc_cidr_block" {
  description = "CIDR for EKS cluster VPC"
  type        = string
  default     = "193.168.0.0/16"
}

variable "instance_tenancy" {
  description = "EC2 instance tenancy"
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "DNS Support for EC2"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "DNS hostname for EC2"
  type        = bool
  default     = true
}

variable "enable_network_address_usage_metrics" {
  description = " Network address metrics"
  type        = bool
  default     = false
}

variable "aws_subnet_private" {
  description = "Private CIDR subnets"
  type        = map(any)
  default = {
    "A" = {
      cidr_block        = "193.168.0.0/20",
      availability_zone = "ap-south-1a"
    },
    "B" = {
      cidr_block        = "193.168.16.0/20",
      availability_zone = "ap-south-1b"
    }
  }
}

variable "aws_subnet_public" {
  description = "Public CIDR subnets"
  type        = map(any)
  default = {
    "A" = {
      cidr_block        = "193.168.100.0/24"
      availability_zone = "ap-south-1a"
    },
    "B" = {
      cidr_block        = "193.168.101.0/24"
      availability_zone = "ap-south-1b"
    }
  }
}

#-------------------------------------------------------------------------------#
# EKS CLUSTER SECTION                                                           #
#-------------------------------------------------------------------------------#

variable "name" {
  description = "Name of the kubernetes cluster"
  type        = string
  default     = null
}

variable "eks_cluster_version" {
  description = "Kubernetes cluster version"
  type        = number
  default     = null
}

variable "eks_node_group_version" {
  description = "Kubernetes node group version"
  type        = number
  default     = null
}

variable "eks_addons" {
  description = "Kubernetes addons"
  type        = map(any)
  default     = null
}

variable "endpoint_private_access" {
  description = "Private EKS API endpoint"
  type        = bool
  default     = false
}

variable "endpoint_public_access" {
  description = "Public EKS API endpoint"
  type        = bool
  default     = true
}

variable "desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Miximum number of nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "ami_type" {
  description = "Type of AMI" # Few valid values AL2_x86_64 | AL2_x86_64_GPU | AL2_ARM_64
  type        = string
  default     = "AL2_x86_64"
}

variable "capacity_type" {
  description = "EC2 Instance capacity type" # Valid values ON_DEMAND, SPOT
  type        = string
  default     = "ON_DEMAND"
}

variable "instance_types" {
  description = "Type EC2 Instance"
  type        = list(any)
  default     = ["t3.small"]
}

variable "disk_size" {
  description = "EC2 Instance disk size"
  type        = number
  default     = 20
}

variable "ec2_ssh_key" {
  description = "SSH key"
  type        = string
  default     = null
}

variable "max_unavailable" {
  description = "Miximum number of nodes that could be unavailable"
  type        = number
  default     = 1
}

#-------------------------------------------------------------------------------#
# OTHERS SECTION                                                                #
#-------------------------------------------------------------------------------#
variable "prefix" {
  description = "Prefix to all terraform resources"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for resources related to EKS"
  type        = map(any)
  default     = null
}

variable "region" {
  description = "Name of the region"
  type        = string
  default     = "ap-south-1"
}

#-------------------------------------------------------------------------------#
# LOCALS                                                                        #
#-------------------------------------------------------------------------------#

locals {
  # "Tags required for EKS cluster"
  # Refer: https://repost.aws/knowledge-center/eks-vpc-subnet-discovery
  # Refer: https://repost.aws/knowledge-center/eks-load-balancers-troubleshooting
  aws_private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = 1
  }
  aws_public_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = 1
  }
}

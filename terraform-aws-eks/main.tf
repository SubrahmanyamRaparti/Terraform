#-------------------------------------------------------------------------------#
# IAM SECTION                                                                   #
#-------------------------------------------------------------------------------#

# Assume Role
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Role For EKS Cluster
resource "aws_iam_role" "aws_iam_role_eks" {
  name               = "${var.prefix}-${var.name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_eks_cluster_aws_managed" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ])
  policy_arn = each.key
  role       = aws_iam_role.aws_iam_role_eks.name
}

resource "aws_iam_policy" "aws_iam_policy_cloudWatch_metrics" {
  name        = "${var.prefix}-${var.name}-policy-cloudWatch-metrics"
  path        = "/"
  description = "To put metric data into cloudwatch"
  policy      = file("policies/PolicyCloudWatchMetrics.json")
}

resource "aws_iam_policy" "aws_iam_policy_ELB_permissions" {
  name        = "${var.prefix}-${var.name}-policy-ELB-permissions"
  path        = "/"
  description = "To describe IGW and addresses"
  policy      = file("policies/PolicyELBPermissions.json")
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_eks_policy_cloudWatch_metrics" {
  policy_arn = aws_iam_policy.aws_iam_policy_cloudWatch_metrics.arn
  role       = aws_iam_role.aws_iam_role_eks.name
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_eks_ELB_permissions" {
  policy_arn = aws_iam_policy.aws_iam_policy_ELB_permissions.arn
  role       = aws_iam_role.aws_iam_role_eks.name
}

# Role For EKS Cluster Managed Nodes
resource "aws_iam_role" "aws_iam_role_eks_nodes" {
  name               = "${var.prefix}-${var.name}-eks-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_eks_worker_node_aws_managed" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ])
  policy_arn = each.key
  role       = aws_iam_role.aws_iam_role_eks_nodes.name
}

resource "aws_iam_policy" "aws_iam_policy_app_mesh" {
  name        = "${var.prefix}-${var.name}-policy-app-mesh"
  path        = "/"
  description = "For service discovery and route53"
  policy      = file("policies/PolicyAppMesh.json")
}

resource "aws_iam_policy" "aws_iam_policy_auto_scaling" {
  name        = "${var.prefix}-${var.name}-policy-auto-scaling"
  path        = "/"
  description = "For EKS nodes to autoscale"
  policy      = file("policies/PolicyAutoScaling.json")
}

resource "aws_iam_policy" "aws_iam_policy_loadbalancer_controller" {
  name        = "${var.prefix}-${var.name}-policy-loadbalancer-controller"
  path        = "/"
  description = "For loadbalancer"
  policy      = file("policies/PolicyAWSLoadBalancerController.json")
}

resource "aws_iam_policy" "aws_iam_policy_external_dns_changset" {
  name        = "${var.prefix}-${var.name}-policy-external-dns-changeset"
  path        = "/"
  description = "Change route53 hosted zone"
  policy      = file("policies/PolicyExternalDNSChangeSet.json")
}

resource "aws_iam_policy" "aws_iam_policy_external_dns_hosted_zones" {
  name        = "${var.prefix}-${var.name}-policy-external-dns-hosted-zones"
  path        = "/"
  description = "List route53 hosted zone"
  policy      = file("policies/PolicyExternalDNSHostedZones.json")
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_eks_app_mesh" {
  policy_arn = aws_iam_policy.aws_iam_policy_app_mesh.arn
  role       = aws_iam_role.aws_iam_role_eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_eks_auto_scaling" {
  policy_arn = aws_iam_policy.aws_iam_policy_auto_scaling.arn
  role       = aws_iam_role.aws_iam_role_eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_eks_loadbalancer_controller" {
  policy_arn = aws_iam_policy.aws_iam_policy_loadbalancer_controller.arn
  role       = aws_iam_role.aws_iam_role_eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_eks_external_dns_changset" {
  policy_arn = aws_iam_policy.aws_iam_policy_external_dns_changset.arn
  role       = aws_iam_role.aws_iam_role_eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_eks_list_external_dns_changset" {
  policy_arn = aws_iam_policy.aws_iam_policy_external_dns_hosted_zones.arn
  role       = aws_iam_role.aws_iam_role_eks_nodes.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html

#-------------------------------------------------------------------------------#
# VPC SECTION                                                                   #
#-------------------------------------------------------------------------------#

# VPC
resource "aws_vpc" "aws_vpc" {
  cidr_block                           = var.vpc_cidr_block
  instance_tenancy                     = var.instance_tenancy
  enable_dns_support                   = var.enable_dns_support
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  tags = merge({ "Name" = "${var.prefix}-${var.name}-eks-cluster-vpc" }, var.tags)
}

# Security Group(s)
resource "aws_security_group" "aws_security_group_eks_nodes" {
  name        = "Allow inbound traffic for EKS nodes from port SSH (22)"
  description = "Allow TLS for EKS nodes"
  vpc_id      = aws_vpc.aws_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "aws_security_group_cluser" {
  name        = "eks-cluster-sg-demo-cluster"
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
  vpc_id      = aws_vpc.aws_vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags)
}

# resource "aws_security_group_rule" "aws_security_group_rule_cluster_1" {
#   type                     = "ingress"
#   description              = "Allow unmanaged nodes to communicate with control plane (all ports)"
#   from_port                = 0
#   to_port                  = 0
#   protocol                 = -1
#   security_group_id        = aws_security_group.aws_security_group_cluser.id
#   source_security_group_id = aws_security_group.aws_security_group_additional.id
# }

resource "aws_security_group_rule" "aws_security_group_rule_cluster_2" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = aws_security_group.aws_security_group_cluser.id
  self              = true
}

# Private Subnet
resource "aws_subnet" "aws_subnet_private" {
  for_each = var.aws_subnet_private

  vpc_id                                      = aws_vpc.aws_vpc.id
  cidr_block                                  = var.aws_subnet_private[each.key].cidr_block
  availability_zone                           = var.aws_subnet_private[each.key].availability_zone
  map_public_ip_on_launch                     = false
  enable_resource_name_dns_a_record_on_launch = true
  private_dns_hostname_type_on_launch         = "ip-name"

  tags = merge({ "Name" = "${var.prefix}-${var.name}-eks-private-subnet-${each.key}" }, var.tags, local.aws_private_subnet_tags)
}

# Public Subnet
resource "aws_subnet" "aws_subnet_public" {
  for_each = var.aws_subnet_public

  vpc_id                                      = aws_vpc.aws_vpc.id
  cidr_block                                  = var.aws_subnet_public[each.key].cidr_block
  availability_zone                           = var.aws_subnet_public[each.key].availability_zone
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
  private_dns_hostname_type_on_launch         = "ip-name"

  tags = merge({ "Name" = "${var.prefix}-${var.name}-eks-public-subnet-${each.key}" }, var.tags, local.aws_public_subnet_tags)
}

# Internet Gateway
resource "aws_internet_gateway" "aws_internet_gateway" {
  vpc_id = aws_vpc.aws_vpc.id

  tags = merge({ "Name" = "${var.prefix}-${var.name}-eks-cluster-ig" }, var.tags)
}

# Elastic IP(s)
resource "aws_eip" "aws_eip_nat" {
  vpc                  = true
  network_border_group = var.region
  depends_on           = [aws_internet_gateway.aws_internet_gateway]

  tags = merge({ "Name" = "${var.prefix}-${var.name}-eip-nat" }, var.tags)
}

# NAT Gateway(s)
resource "aws_nat_gateway" "aws_nat_gateway" {
  allocation_id     = aws_eip.aws_eip_nat.id
  subnet_id         = aws_subnet.aws_subnet_public["A"].id
  connectivity_type = "public"

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.aws_internet_gateway]

  tags = merge({ "Name" = "${var.prefix}-${var.name}-nat" }, var.tags)
}

# Route Table(s) & Association
resource "aws_route_table" "aws_route_table_private_1" {
  vpc_id = aws_vpc.aws_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws_nat_gateway.id
  }

  tags = merge({ "Name" = "${var.prefix}-${var.name}-private-route-table-1" }, var.tags)
}

resource "aws_route_table" "aws_route_table_private_2" {
  vpc_id = aws_vpc.aws_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws_nat_gateway.id
  }

  tags = merge({ "Name" = "${var.prefix}-${var.name}-private-route-table-2" }, var.tags)
}

resource "aws_route_table" "aws_route_table_public" {
  vpc_id = aws_vpc.aws_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_internet_gateway.id
  }

  tags = merge({ "Name" = "${var.prefix}-${var.name}-public-route-table" }, var.tags)
}

resource "aws_route_table_association" "aws_route_table_private_1" {
  subnet_id      = aws_subnet.aws_subnet_private["A"].id
  route_table_id = aws_route_table.aws_route_table_private_1.id
}

resource "aws_route_table_association" "aws_route_table_private_2" {
  subnet_id      = aws_subnet.aws_subnet_private["B"].id
  route_table_id = aws_route_table.aws_route_table_private_2.id
}

resource "aws_route_table_association" "aws_route_table_public" {
  for_each       = var.aws_subnet_public
  subnet_id      = aws_subnet.aws_subnet_public[each.key].id
  route_table_id = aws_route_table.aws_route_table_public.id
}

#-------------------------------------------------------------------------------#
# EKS CLUSTER SECTION                                                           #
#-------------------------------------------------------------------------------#

resource "aws_eks_cluster" "aws_eks_cluster" {
  name     = var.name
  version  = var.eks_cluster_version
  role_arn = aws_iam_role.aws_iam_role_eks.arn

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [aws_security_group.aws_security_group_cluser.id]
    subnet_ids              = concat([for _ in aws_subnet.aws_subnet_public : _.id], [for _ in aws_subnet.aws_subnet_private : _.id])
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # To ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.aws_iam_role_policy_attachment_eks_cluster_aws_managed
  ]

  tags = var.tags
}

resource "aws_eks_node_group" "aws_eks_node_group" {
  cluster_name  = aws_eks_cluster.aws_eks_cluster.name
  node_role_arn = aws_iam_role.aws_iam_role_eks_nodes.arn

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  subnet_ids = [for _ in aws_subnet.aws_subnet_private : _.id]

  ami_type             = var.ami_type
  capacity_type        = var.capacity_type
  disk_size            = var.disk_size
  force_update_version = false
  instance_types       = var.instance_types
  labels               = { node-name : "green-node" }
  node_group_name      = "${var.name}-node-group-a"

  remote_access {
    ec2_ssh_key               = var.ec2_ssh_key
    source_security_group_ids = [aws_security_group.aws_security_group_eks_nodes.id]
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  tags    = var.tags
  version = var.eks_node_group_version

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.aws_iam_role_policy_attachment_eks_worker_node_aws_managed
  ]
}

resource "aws_eks_addon" "aws_eks_addon" {
  for_each = var.eks_addons

  cluster_name  = aws_eks_cluster.aws_eks_cluster.name
  addon_name    = each.key
  addon_version = each.value
}
prefix      = "terraform"
name        = "alpha-centauri"
ec2_ssh_key = "jenkins"

eks_cluster_version    = 1.25
eks_node_group_version = 1.25
eks_addons = {
  coredns            = "v1.9.3-eksbuild.2",
  vpc-cni            = "v1.12.2-eksbuild.1",
  kube-proxy         = "v1.25.6-eksbuild.1",
  aws-ebs-csi-driver = "v1.22.0-eksbuild.2"
}
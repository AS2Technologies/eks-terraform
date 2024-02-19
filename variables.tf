variable "eks_cluster_role_name" {
  type = string
  default = "eks-cluster-role"
}

variable "eks_cluster_name" {
  type = string
  default = "eks-demo"
}

variable "node_group_name" {
  type = string
  default = "eks-demo-nodegroup"
}

variable "kubernetes_version" {
  type = string
  default = "1.28"
}


variable "vpc_name" {
  type = string
  default = "my-work-vpc"
}
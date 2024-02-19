resource "aws_iam_role" "eks_cluster_role" {
    name = var.eks_cluster_role_name
    assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
    managed_policy_arns = [data.aws_iam_policy.cluster_policy.arn]
}

resource "aws_iam_role" "ec2_nodegroup_role" {
  name = var.node_group_name
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_eks_cluster" "eks_demo" {
  name = var.eks_cluster_name
  version = var.kubernetes_version
  role_arn = aws_iam_role.eks_cluster_role.arn
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = [data.aws_subnet.us-east-1a.id, data.aws_subnet.us-east-1b.id]
  }

  tags = {
    Name = var.eks_cluster_name
  }
}

resource "aws_eks_node_group" "my_node_group" {
  cluster_name = var.eks_cluster_name
  node_group_name = var.node_group_name
  node_role_arn = aws_iam_role.ec2_nodegroup_role.arn
  subnet_ids = [data.aws_subnet.us-east-1a.id, data.aws_subnet.us-east-1b.id]
  version = var.kubernetes_version
  instance_types = ["t3.medium"]
  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 1
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [ aws_eks_cluster.eks_demo ]
}


resource "aws_eks_access_entry" "eks_access" {
  cluster_name      = aws_eks_cluster.eks_demo.name
  principal_arn     = data.aws_iam_user.my-user.arn
  type              = "STANDARD"
  depends_on = [ aws_eks_cluster.eks_demo ]
}

resource "aws_eks_access_policy_association" "eks_admin_access_policy" {
  cluster_name  = aws_eks_cluster.eks_demo.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = data.aws_iam_user.my-user.arn

  access_scope {
    type       = "cluster"
  }
  depends_on = [ aws_eks_access_entry.eks_access ]
}

resource "aws_eks_access_policy_association" "cluster_admin_access_policy" {
  cluster_name  = aws_eks_cluster.eks_demo.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_iam_user.my-user.arn
  depends_on = [ aws_eks_access_entry.eks_access ]
  access_scope {
    type       = "cluster"
  }
}
data "aws_iam_policy" "cluster_policy" {
  name = "AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "ec2_instance_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_vpc" "my-vpc" {
  default = true
  # tags = {
  #   Name = var.vpc_name
  # }
}

# output "vpc" {
#   value = data.aws_iam_user.example
# }

# data "aws_subnets" "cluster_subnet" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.my-vpc.id]
#   }
# }

data "aws_subnet" "us-east-1a" {
  vpc_id = data.aws_vpc.my-vpc.id
  availability_zone = "us-east-1a"

}

data "aws_subnet" "us-east-1b" {
  vpc_id = data.aws_vpc.my-vpc.id
  availability_zone = "us-east-1b"

}

data "aws_iam_user" "my-user" {
  user_name = "cloud_user"
}
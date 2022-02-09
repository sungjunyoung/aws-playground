resource "aws_iam_role" "play_nodegroup" {
  name = "eks_play_nodegroup"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "play_nodegroup_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.play_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "play_nodegroup_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.play_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "play_nodegroup_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.play_nodegroup.name
}

resource "aws_eks_node_group" "play" {
  cluster_name    = aws_eks_cluster.play.name
  node_group_name = "play"
  node_role_arn   = aws_iam_role.play_nodegroup.arn
  subnet_ids      = aws_subnet.play[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.play_nodegroup_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.play_nodegroup_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.play_nodegroup_AmazonEC2ContainerRegistryReadOnly,
  ]
}

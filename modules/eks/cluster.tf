resource "aws_iam_role" "play_cluster" {
  name = "eks_play_cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "play_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.play_cluster.name
}

resource "aws_iam_role_policy_attachment" "play_cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.play_cluster.name
}

resource "aws_security_group" "play_cluster" {
  name        = "eks_play_cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.play.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks_play"
  }
}

resource "aws_security_group_rule" "play_cluster_ingress" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.play_cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "play" {
  name     = var.cluster_name
  role_arn = aws_iam_role.play_cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.play_cluster.id]
    subnet_ids         = aws_subnet.play[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.play_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.play_cluster_AmazonEKSVPCResourceController,
  ]
}
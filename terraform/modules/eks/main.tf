############################################
# Data
############################################
#data "aws_caller_identity" "current" {}

# --------------------------------------------------
# IAM Role for EKS Cluster
# --------------------------------------------------
resource "aws_iam_role" "eks_cluster" {
  name = "${local.name_prefix}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-eks-cluster-role"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# --------------------------------------------------
# Security Group for EKS Cluster
# --------------------------------------------------
resource "aws_security_group" "eks_cluster" {
  name        = "${local.name_prefix}-eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-eks-cluster-sg"
  })
}

resource "aws_security_group_rule" "eks_cluster_ingress_bastion" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = var.bastion_sg_id   # pass this from root module
  description              = "Allow bastion to access EKS API"
}

resource "aws_security_group_rule" "eks_cluster_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}
# --------------------------------------------------
# EKS Cluster
# --------------------------------------------------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}



############################################
# OIDC Provider (equivalent to withOIDC: true)
############################################
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-oidc-provider"
  })
}

# --------------------------------------------------
# IAM Role for Node Group
# --------------------------------------------------
resource "aws_iam_role" "node_group" {
  name = "${local.name_prefix}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-eks-nodegroup-role"
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# --------------------------------------------------
# EKS Managed Node Group
# --------------------------------------------------
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types
  capacity_type   = var.capacity_type
  disk_size       = var.disk_size

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_readonly,
    #aws_iam_role_policy_attachment.ssm_core,
    aws_eks_cluster.this
  ]

  tags = merge(var.tags, {
    Name = var.node_group_name
  })
}

############################################
# IAM Role for EBS CSI Add-on IRSA
############################################
resource "aws_iam_role" "ebs_csi_role" {
  name = "${var.cluster_name}-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-ebs-csi-role"
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

############################################
# EBS CSI Add-on
############################################
resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.ebs_csi_policy
  ]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-ebs-csi-addon"
  })
}

################## default storage class
provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name", aws_eks_cluster.this.name,
      "--region", var.aws_region,
      "--output", "json"
    ]
  }
}

resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    type   = "gp3"
    fsType = "ext4"
  }

  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}

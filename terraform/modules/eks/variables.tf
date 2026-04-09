variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}
variable "bastion_sg_id" {
  description = "Security Group ID of Bastion Host"
  type        = string
}
variable "subnet_ids" {
  description = "Private subnet IDs for EKS cluster and node group"
  type        = list(string)
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "endpoint_public_access" {
  type    = bool
  default = true
}

variable "node_group_name" {
  type = string
}

variable "instance_types" {
  type = list(string)
}

variable "capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_irsa" {
  description = "Create IAM OIDC provider for the EKS cluster"
  type        = bool
  default     = true
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver as EKS managed addon"
  type        = bool
  default     = true
}

variable "ebs_csi_addon_version" {
  description = "Optional explicit version for aws-ebs-csi-driver addon"
  type        = string
  default     = null
}


module "vpc" {
  source               = "../../modules/vpc"
  project_name         = var.project_name
  environment          = var.environment
  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  nat_gateway_count    = var.nat_gateway_count

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"

  }
}

module "eks" {
  source = "../../modules/eks"
  aws_region              = var.aws_region
  project_name            = var.project_name
  environment             = var.environment
  cluster_name            = var.cluster_name
  cluster_version         = var.cluster_version
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnet_ids
  #vpc_cidr                = module.vpc.vpc_cidr
  bastion_sg_id           = module.bastion.security_group_id

  endpoint_private_access = true
  endpoint_public_access  = true

  node_group_name = var.node_group_name
  instance_types  = var.instance_types
  capacity_type   = "ON_DEMAND"
  desired_size    = var.desired_size
  min_size        = var.min_size
  max_size        = var.max_size
  disk_size       = 20

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

locals {
  vpc_name    = var.vpc_name != null ? var.vpc_name : "${var.project_name}-${var.environment}-vpc"
  name_prefix = "${var.project_name}-${var.environment}"
}
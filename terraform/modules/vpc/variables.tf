variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways"
  type        = number
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
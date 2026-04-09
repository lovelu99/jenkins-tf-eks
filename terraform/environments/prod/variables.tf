variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_name" {
  type    = string
  default = null
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "nat_gateway_count" {
  type = number
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "node_group_name" {
  type = string
}

variable "instance_types" {
  type = list(string)
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

variable "ami_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "my_ip_cidr" {
  type = string
}

variable "allow_all_ip" {
  type = string
} 
variable "bastion_instance_type" {
  type = string
}

variable "jenkins_instance_type" {
  type = string
}

variable "sonarqube_instance_type" {
  type = string
}

variable "name" {
  description = "Instance name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Assign public IP"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = null
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed for SSH"
  type        = list(string)
  default     = []
}

variable "ingress_rules" {
  description = "Additional ingress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "root_volume_size" {
  description = "Root EBS volume size"
  type        = number
  default     = 20
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

variable "allow_all_ip" {
  type = string
 default="0.0.0.0/0"
}
aws_region   = "us-east-1"
project_name = "myapp"
environment  = "prod"
vpc_name     = "my-vpc"

vpc_cidr = "10.10.0.0/16"

azs = [
  "us-east-1a",
  "us-east-1b"
]

public_subnet_cidrs = [
  "10.10.0.0/20",
  "10.10.16.0/20"
]

private_subnet_cidrs = [
  "10.10.32.0/20",
  "10.10.48.0/20"
]

nat_gateway_count = 1

cluster_name    = "prod-eks-cluster"
cluster_version = "1.34"

node_group_name = "prod-eks-ng"

instance_types = [
  "t3.small"
]

desired_size = 3
min_size     = 2
max_size     = 4

ami_id = "ami-0ec10929233384c7f" # example Amazon Linux 2023, replace with your region-valid AMI
key_name = "shefat-va-key"
my_ip_cidr = "74.72.247.231/32"

allow_all_ip            = "0.0.0.0/0"
bastion_instance_type   = "t3.micro"
jenkins_instance_type   = "t3.small"
sonarqube_instance_type = "c7i-flex.large"


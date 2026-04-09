

resource "aws_vpc" "this" {
  cidr_block                = var.vpc_cidr
  enable_dns_hostnames      = true
  enable_dns_support        = true

  tags  = merge(var.tags, { Name = "${local.name_prefix}-vpc" })
}
resource "aws_internet_gateway" "this" {
  vpc_id            = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${local.name_prefix}-igw"
  })
}
#public subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name                     = "${local.name_prefix}-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  })
}

########################################
###### private subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(var.tags, {
    Name                              = "${local.name_prefix}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
  })

}

#####################################
##### elastic ips for nat
resource "aws_eip" "nat" {
  count  = var.nat_gateway_count
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-eip-${count.index + 1}"
  })
  depends_on = [aws_internet_gateway.this]

}

##################################3
#### nat gateway
######## if 1 nat, it will place public subnet 1
######## if 2 nat, one in each public subnet mainly production

resource "aws_nat_gateway" "this" {
  count         = var.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-nat-${count.index + 1}"
  })
  depends_on = [aws_internet_gateway.this]
}

###############
### public route table . share by both subnet

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(var.tags, {
    Name = "${local.name_prefix}-public-rt"
  })

}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


############################
# private route table. if nat_gateway is 1 then  both private subnets route to nat 1
# private route table. if nat_gateway is 2 then  each private subnet route to own nat in same az

resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_count == 1 ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
  }
  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-rt-${count.index + 1}"
  })
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id

}
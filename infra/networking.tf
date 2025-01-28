resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.project}-igw"
  }
}

resource "aws_eip" "main" {
  count = length(var.vpc_nat_gateway_subnets.cidr)
  tags = {
    Name = "${local.project}-natgw-${count.index}"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_nat_gateway" "main" {
  depends_on = [aws_internet_gateway.main]

  count             = length(var.vpc_nat_gateway_subnets.cidr)
  connectivity_type = "public"
  subnet_id         = element(aws_subnet.nat_gateway[*].id, count.index)
  allocation_id     = element(aws_eip.main[*].id, count.index)

  tags = {
    Name = "${local.project}-natgw-${count.index}"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_subnet" "load_balancer" {
  count                   = length(var.vpc_load_balancer_subnets.cidr)
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index]
  cidr_block              = var.vpc_load_balancer_subnets.cidr[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  tags = {
    Name = "${local.project}-${var.vpc_load_balancer_subnets.name}-${count.index}"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_subnet" "firewall" {
  count                   = length(var.vpc_firewall_subnets.cidr)
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index]
  cidr_block              = var.vpc_firewall_subnets.cidr[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  tags = {
    Name = "${local.project}-${var.vpc_firewall_subnets.name}-${count.index}"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_subnet" "nat_gateway" {
  count                   = length(var.vpc_nat_gateway_subnets.cidr)
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index]
  cidr_block              = var.vpc_nat_gateway_subnets.cidr[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  tags = {
    Name = "${local.project}-${var.vpc_nat_gateway_subnets.name}-${count.index}"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_subnet" "compute" {
  count                   = length(var.vpc_compute_subnets.cidr)
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index]
  cidr_block              = var.vpc_compute_subnets.cidr[count.index]
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.main.id
  tags = {
    Name = "${local.project}-${var.vpc_compute_subnets.name}-${count.index}"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}

## Routing

resource "aws_route_table" "nat_gateway" {
  count  = length(var.vpc_nat_gateway_subnets.cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }

  # route {
  #   cidr_block      = "0.0.0.0/0"
  #   vpc_endpoint_id = local.firewall_endpoint_ids[count.index]
  # }

  tags = {
    Name = "${local.project}-${var.vpc_nat_gateway_subnets.name}-rt-${count.index}"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_route_table_association" "nat_gateway" {
  count = length(var.vpc_nat_gateway_subnets.cidr)

  subnet_id      = element(aws_subnet.nat_gateway[*].id, count.index)
  route_table_id = element(aws_route_table.nat_gateway[*].id, count.index)
}

resource "aws_route_table" "firewall" {
  count  = length(var.vpc_firewall_subnets.cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.project}-${var.vpc_firewall_subnets.name}-rt-${count.index}"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_route_table_association" "firewall" {
  count = length(var.vpc_firewall_subnets.cidr)

  subnet_id      = element(aws_subnet.firewall[*].id, count.index)
  route_table_id = element(aws_route_table.firewall[*].id, count.index)
}

resource "aws_route_table" "compute" {
  count  = length(var.vpc_compute_subnets.cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main[*].id, count.index)
  }

  tags = {
    Name = "${local.project}-${var.vpc_compute_subnets.name}-rt-${count.index}"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_route_table_association" "compute" {
  count = length(var.vpc_compute_subnets.cidr)

  subnet_id      = element(aws_subnet.compute[*].id, count.index)
  route_table_id = element(aws_route_table.compute[*].id, count.index)
}

resource "aws_route_table" "internet_gateway" {
  #depends_on = [module.network_firewall_dataexfiltration]
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }

  # dynamic "route" {
  #   for_each = range(length(var.vpc_nat_gateway_subnets.cidr))
  #   content {
  #     cidr_block      = var.vpc_nat_gateway_subnets.cidr[route.key]
  #     vpc_endpoint_id = local.firewall_endpoint_ids[route.key]
  #   }
  # }

  tags = {
    Name = "${local.project}-igw-rt"
  }
}

resource "aws_route_table_association" "internet_gateway" {
  gateway_id     = aws_internet_gateway.main.id
  route_table_id = aws_route_table.internet_gateway.id
}

resource "aws_route_table" "load_balancer" {
  count  = length(var.vpc_load_balancer_subnets.cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.project}-${var.vpc_load_balancer_subnets.name}-rt-${count.index}"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_route_table_association" "load_balancer" {
  count = length(var.vpc_load_balancer_subnets.cidr)

  subnet_id      = element(aws_subnet.load_balancer[*].id, count.index)
  route_table_id = element(aws_route_table.load_balancer[*].id, count.index)
}

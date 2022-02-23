data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "worker" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name"                                      = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "worker" {
  count                   = 3
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  vpc_id                  = aws_vpc.worker.id
  map_public_ip_on_launch = true
  tags = {
    "Name"                                      = "${var.cluster_name}-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_internet_gateway" "worker" {
  vpc_id = aws_vpc.worker.id
  tags = {
    Name = var.cluster_name
  }
}

resource "aws_route_table" "worker" {
  vpc_id = aws_vpc.worker.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.worker.id
  }
}

resource "aws_route_table_association" "worker" {
  count          = 3
  subnet_id      = aws_subnet.worker[count.index].id
  route_table_id = aws_route_table.worker.id
}

resource "aws_security_group" "worker" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.worker.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.cluster_name
  }
}

resource "aws_subnet" "rds" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${10+count.index}.0/24"
  vpc_id                  = aws_vpc.worker.id
  tags = {
    "Name" = "${var.cluster_name}-rds-${count.index}"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = aws_subnet.rds[*].id
}

resource "aws_security_group" "rds" {
  for_each = var.rds_secrets_arns

  name   = "${each.key}-${var.cluster_name}-rds-sg"
  description = "Communication with the RDS database"
  vpc_id = aws_vpc.worker.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.worker.cidr_block]
  }
}
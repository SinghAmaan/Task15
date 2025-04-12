# --------------------------
# VPC Configuration
# --------------------------
resource "aws_vpc" "aws_final_project" {
  cidr_block = "10.10.10.0/24"
  tags = {
    Name = "AWS-FINAL-PROJECT"
  }
}

# --------------------------
# Internet Gateway
# --------------------------
resource "aws_internet_gateway" "alb_igw" {
  vpc_id = aws_vpc.aws_final_project.id
  tags = {
    Name = "AWS-FINAL-ALB-IGW"
  }
}

# --------------------------
# Availability Zones (Dynamic)
# --------------------------
data "aws_availability_zones" "available" {}

# --------------------------
# DB Subnets (.0, .16, .32) — .48 reserved
# --------------------------
resource "aws_subnet" "db_private" {
  count = 3
  vpc_id = aws_vpc.aws_final_project.id
  cidr_block = element([
    "10.10.10.0/28",
    "10.10.10.16/28",
    "10.10.10.32/28"
  ], count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "AWS-FINAL-DB-PRIVATE-${count.index + 1}"
  }
}

# --------------------------
# App Subnets (.64, .80, .96) — .112 reserved
# --------------------------
resource "aws_subnet" "app_private" {
  count = 3
  vpc_id = aws_vpc.aws_final_project.id
  cidr_block = element([
    "10.10.10.64/28",
    "10.10.10.80/28",
    "10.10.10.96/28"
  ], count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "AWS-FINAL-APP-PRIVATE-${count.index + 1}"
  }
}

# --------------------------
# ALB Subnets (.128, .144, .160) — .176 reserved
# --------------------------
resource "aws_subnet" "alb_public" {
  count = 3
  vpc_id = aws_vpc.aws_final_project.id
  cidr_block = element([
    "10.10.10.128/28",
    "10.10.10.144/28",
    "10.10.10.160/28"
  ], count.index)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "AWS-FINAL-ALB-PUBLIC-${count.index + 1}"
  }
}

# --------------------------
# Jump Subnet (.192)
# --------------------------
resource "aws_subnet" "jump_public" {
  vpc_id = aws_vpc.aws_final_project.id
  cidr_block = "10.10.10.192/28"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "AWS-FINAL-JUMP-PUBLIC"
  }
}

# --------------------------
# Route Tables
# --------------------------
resource "aws_route_table" "app_server_rt" {
  vpc_id = aws_vpc.aws_final_project.id
  tags = {
    Name = "APP-SERVER-RT"
  }
}

resource "aws_route_table" "db_server_rt" {
  vpc_id = aws_vpc.aws_final_project.id
  tags = {
    Name = "DB-SERVER-RT"
  }
}

resource "aws_route_table" "alb_server_rt" {
  vpc_id = aws_vpc.aws_final_project.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.alb_igw.id
  }
  tags = {
    Name = "ALB-SERVER-RT"
  }
}

resource "aws_route_table" "jump_server_rt" {
  vpc_id = aws_vpc.aws_final_project.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.alb_igw.id
  }
  tags = {
    Name = "JUMP-SERVER-RT"
  }
}

# --------------------------
# Route Table Associations
# --------------------------
resource "aws_route_table_association" "app_server_rt" {
  count = 3
  subnet_id = aws_subnet.app_private[count.index].id
  route_table_id = aws_route_table.app_server_rt.id
}

resource "aws_route_table_association" "db_server_rt" {
  count = 3
  subnet_id = aws_subnet.db_private[count.index].id
  route_table_id = aws_route_table.db_server_rt.id
}

resource "aws_route_table_association" "alb_server_rt" {
  count = 3
  subnet_id = aws_subnet.alb_public[count.index].id
  route_table_id = aws_route_table.alb_server_rt.id
}

resource "aws_route_table_association" "jump_server_rt" {
  subnet_id = aws_subnet.jump_public.id
  route_table_id = aws_route_table.jump_server_rt.id
}
# --------------------------
# Security Groups
# --------------------------
resource "aws_security_group" "alb_sg" {
  name        = "AWS-FINAL-ALB-SG"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.aws_final_project.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "AWS-FINAL-ALB-SG"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "AWS-FINAL-APP-SG"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.aws_final_project.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "AWS-FINAL-APP-SG"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "AWS-FINAL-DB-SG"
  description = "Allow MySQL"
  vpc_id      = aws_vpc.aws_final_project.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "AWS-FINAL-DB-SG"
  }
}

resource "aws_security_group" "jump_sg" {
  name        = "AWS-FINAL-JUMP-SG"
  description = "Allow SSH & HTTP"
  vpc_id      = aws_vpc.aws_final_project.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "AWS-FINAL-JUMP-SG"
  }
}
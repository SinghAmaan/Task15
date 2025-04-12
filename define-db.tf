# ---------------------------------------------
# ✅ DB Subnet Group using your private subnets
# ---------------------------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = aws_subnet.db_private[*].id

  tags = {
    Name = "My DB Subnet Group"
  }
}

# ---------------------------------------------
# ✅ RDS MySQL 8.0 Instance (Private)
# ---------------------------------------------
resource "aws_db_instance" "mysql" {
  identifier              = "my-mysql-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = "Singh"
  password                = "singh123"
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  deletion_protection     = true

  tags = {
    Name = "MySQL-Database"
  }
}

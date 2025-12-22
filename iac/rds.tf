# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow inbound access from DMS"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For demo purposes only. Real world: restrict to DMS sg or specific IP.
  }
}

# RDS Subnet Group


# Data source to get default VPC subnets (making it runnable)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_subnet_group" "real_default" {
  name       = "real-rds-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

# Source RDS Instance (PostgreSQL)
resource "aws_db_instance" "source" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = "db.t3.micro"
  db_name              = "example_db"
  username             = "example_user"
  password             = "ExamplePassword123!" # In real world, use Secrets Manager
  parameter_group_name = "default.postgres14"
  skip_final_snapshot  = true
  publicly_accessible  = true # For demo simplicity

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.real_default.name
}

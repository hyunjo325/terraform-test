resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-rds-sg"
  description = "Allow DB access from ECS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-rds-sg"
  }
}

resource "aws_db_instance" "this" {
  identifier              = "${var.name}-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  port                    = var.port
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false

  tags = {
    Name = "${var.name}-rds"
  }
}
module "rds" {
  source                = "../modules/rds"
  name                  = "prod"
  db_name               = "mydb"
  username              = "admin"
  password              = "changeme1234!" # 민감정보! 실전에서는 secrets로 분리 추천
  port                  = 3306
  vpc_id                = module.prod_vpc.vpc_id
  subnet_ids            = module.prod_vpc.private_subnet_ids
  ecs_security_group_id = aws_security_group.ecs_sg.id
}

output "rds_endpoint" {
  value = module.rds.endpoint
}


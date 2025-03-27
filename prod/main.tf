# prod/main.tf
data "terraform_remote_state" "dev" {
  backend = "s3"
  config = {
    bucket = "terraform-evan-tfstate"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-2"
  }
}


module "prod_vpc" {
  source     = "../modules/vpc"
  name       = "prod"
  cidr_block = "10.20.0.0/16"
  azs        = ["ap-northeast-2a", "ap-northeast-2c"]
  # prod VPC → dev VPC 라우팅 설정
  peer_cidr_block           = "10.10.0.0/16" # dev VPC의 CIDR
  route_table_ids_to_update = module.prod_vpc.public_route_table_ids
}
module "prod_alb" {
  source             = "../modules/alb"
  name               = "prod"
  vpc_id             = module.prod_vpc.vpc_id
  subnet_ids         = module.prod_vpc.public_subnet_ids
  security_group_id  = aws_security_group.alb_sg.id
  target_port        = 80
  acm_certificate_arn = "arn:aws:acm:ap-northeast-2:390403876841:certificate/dba5c1c4-d0bf-404b-8bc3-4180c8ccff5d"

}
resource "aws_security_group" "alb_sg" {
  name        = "prod-alb-sg"
  description = "Allow HTTP"
  vpc_id      = module.prod_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "prod-alb-sg"
  }
}
module "ecr_backend" {
  source = "../modules/ecr"
  name   = "prod-backend"
}

module "ecr_ai" {
  source = "../modules/ecr"
  name   = "prod-ai"
}

output "alb_dns" {
  value = module.prod_alb.alb_dns_name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "prod-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_security_group" "ecs_sg" {
  name        = "prod-ecs-sg"
  description = "Allow ALB to ECS"
  vpc_id      = module.prod_vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prod-ecs-sg"
  }
}
module "ecs_backend" {
  source            = "../modules/ecs"
  cluster_name      = "prod-cluster"
  family            = "prod-backend-task"
  service_name      = "prod-backend-service"
  container_name    = "backend"
  image             = "390403876841.dkr.ecr.ap-northeast-2.amazonaws.com/prod-backend:latest"
  cpu               = "256"
  memory            = "512"
  container_port    = 80
  vpc_id            = module.prod_vpc.vpc_id
  subnet_ids        = module.prod_vpc.private_subnet_ids
  security_group_id = aws_security_group.ecs_sg.id
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  target_group_arn  = module.prod_alb.target_group_arn
  lb_listener_arn = module.prod_alb.listener_arn
}

module "ecs_ai" {
  source             = "../modules/ecs"
  cluster_name       = "prod-cluster"
  family             = "prod-ai-task"
  service_name       = "prod-ai-service"
  container_name     = "ai"
  image              = module.ecr_ai.repository_url
  cpu                = "256"
  memory             = "512"
  container_port     = 80
  vpc_id             = module.prod_vpc.vpc_id
  subnet_ids         = module.prod_vpc.private_subnet_ids
  security_group_id  = aws_security_group.ecs_sg.id
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  target_group_arn   = module.prod_alb.target_group_arn
  lb_listener_arn    = module.prod_alb.listener_arn
}

module "s3_fe" {
  source = "../modules/s3"
  name   = "prod-fe-static-site"
}

output "fe_site_url" {
  value = module.s3_fe.website_endpoint
}
#module "vpc_peering_dev_to_prod" {
 # source      = "../modules/peering"
 # name        = "dev-to-prod"
 # vpc_id      = data.terraform_remote_state.dev.outputs.vpc_id
 # peer_vpc_id = module.prod_vpc.vpc_id
#}
output "prod_alb_arn" {
  value = module.prod_alb.alb_arn
}

module "rds" {
  source = "../modules/rds"

  identifier        = "prod-db"
  username          = "admin"
  password          = "your-secure-password"
  db_name           = "prod_db"
  security_group_id = aws_security_group.rds_sg.id
  subnet_group_name = aws_db_subnet_group.rds.name
}

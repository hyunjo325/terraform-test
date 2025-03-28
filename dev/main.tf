# dev/main.tf
module "dev_vpc" {
  source     = "../modules/vpc"
  name       = "dev"
  cidr_block = "10.10.0.0/16"
  azs        = ["ap-northeast-2a", "ap-northeast-2c"]

  ecs_private_subnet_cidrs = ["10.10.128.0/20", "10.10.144.0/20"]
  db_private_subnet_cidrs  = ["10.10.160.0/20", "10.10.176.0/20"]
}
module "dev_alb" {
  source             = "../modules/alb"
  name               = "dev"
  vpc_id             = module.dev_vpc.vpc_id
  subnet_ids         = module.dev_vpc.public_subnet_ids
  security_group_id  = aws_security_group.alb_sg.id
  target_port        = 80
  acm_certificate_arn = "arn:aws:acm:ap-northeast-2:390403876841:certificate/dba5c1c4-d0bf-404b-8bc3-4180c8ccff5d" 
}
resource "aws_security_group" "alb_sg" {
  name        = "dev-alb-sg"
  description = "Allow HTTP"
  vpc_id      = module.dev_vpc.vpc_id

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
    Name = "dev-alb-sg"
  }
}
module "ecr_backend" {
  source = "../modules/ecr"
  name   = "dev-backend"
}

module "ecr_ai" {
  source = "../modules/ecr"
  name   = "dev-ai"
}

output "alb_dns" {
  value = module.dev_alb.alb_dns_name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

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
  name        = "dev-ecs-sg"
  description = "Allow ALB to ECS"
  vpc_id      = module.dev_vpc.vpc_id

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
    Name = "dev-ecs-sg"
  }
}
module "ecs_backend" {
  source            = "../modules/ecs"
  cluster_name      = "dev-cluster"
  family            = "dev-backend-task"
  service_name      = "dev-backend-service"
  container_name    = "backend"
  image             = "390403876841.dkr.ecr.ap-northeast-2.amazonaws.com/dev-backend:latest"
  cpu               = "256"
  memory            = "512"
  container_port    = 80
  vpc_id            = module.dev_vpc.vpc_id
  subnet_ids        = module.dev_vpc.ecs_private_subnet_ids
  security_group_id = aws_security_group.ecs_sg.id
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  target_group_arn  = module.dev_alb.target_group_arn
  lb_listener_arn = module.dev_alb.listener_arn
}

module "ecs_ai" {
  source             = "../modules/ecs"
  cluster_name       = "dev-cluster"
  family             = "dev-ai-task"
  service_name       = "dev-ai-service"
  container_name     = "ai"
  image              = module.ecr_ai.repository_url
  cpu                = "256"
  memory             = "512"
  container_port     = 80
  vpc_id             = module.dev_vpc.vpc_id
  subnet_ids         = module.dev_vpc.ecs_private_subnet_ids
  security_group_id  = aws_security_group.ecs_sg.id
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  target_group_arn   = module.dev_alb.target_group_arn
  lb_listener_arn    = module.dev_alb.listener_arn
}

module "s3_fe" {
  source = "../modules/s3"
  name   = "dev-fe-static-site"
}

output "fe_site_url" {
  value = module.s3_fe.website_endpoint
}

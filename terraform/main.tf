############################################
# VPC
############################################

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.environment
  }
}

############################################
# INTERNET GATEWAY
############################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

############################################
# PUBLIC SUBNETS
############################################

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  cidr_block = var.public_subnet_cidrs[count.index]

  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-${count.index + 1}"
    Environment = var.environment
    Type        = "public"
  }
}

############################################
# PRIVATE ECS SUBNETS
############################################

resource "aws_subnet" "private_ecs" {
  count = length(var.private_ecs_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  cidr_block = var.private_ecs_subnet_cidrs[count.index]

  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.app_name}-ecs-private-${count.index + 1}"
    Environment = var.environment
    Type        = "private-ecs"
  }
}

############################################
# PRIVATE DATABASE SUBNETS
############################################

resource "aws_subnet" "private_db" {
  count = length(var.private_db_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  cidr_block = var.private_db_subnet_cidrs[count.index]

  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.app_name}-db-private-${count.index + 1}"
    Environment = var.environment
    Type        = "private-db"
  }
}

############################################
# PUBLIC ROUTE TABLE
############################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-public-rt"
  }
}

############################################
# PUBLIC ROUTE ASSOCIATION
############################################

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public.id
}

############################################
# NAT EIP
############################################

resource "aws_eip" "nat" {
  domain = "vpc"

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name = "${var.app_name}-nat-eip"
  }
}

############################################
# NAT GATEWAY
############################################

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public[0].id

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name = "${var.app_name}-nat"
  }
}

############################################
# PRIVATE ECS ROUTE TABLE
############################################

resource "aws_route_table" "private_ecs" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-ecs-private-rt"
  }
}

############################################
# PRIVATE ECS ROUTE ASSOCIATION
############################################

resource "aws_route_table_association" "private_ecs" {
  count = length(aws_subnet.private_ecs)

  subnet_id = aws_subnet.private_ecs[count.index].id

  route_table_id = aws_route_table.private_ecs.id
}

############################################
# PRIVATE DB ROUTE TABLE
############################################

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-db-private-rt"
  }
}

############################################
# PRIVATE DB ROUTE ASSOCIATION
############################################

resource "aws_route_table_association" "private_db" {
  count = length(aws_subnet.private_db)

  subnet_id = aws_subnet.private_db[count.index].id

  route_table_id = aws_route_table.private_db.id
}

############################################
# ALB SECURITY GROUP
############################################

resource "aws_security_group" "alb" {
  name = "${var.app_name}-alb-sg"

  description = "ALB security group"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.app_name}-alb-sg"
  }
}

############################################
# FRONTEND SECURITY GROUP
############################################

resource "aws_security_group" "frontend" {
  name = "${var.app_name}-frontend-sg"

  description = "Frontend ECS security group"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "Frontend from ALB"

    from_port = var.frontend_port
    to_port   = var.frontend_port

    protocol = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.app_name}-frontend-sg"
  }
}

############################################
# BACKEND SECURITY GROUP
############################################

resource "aws_security_group" "backend" {
  name = "${var.app_name}-backend-sg"

  description = "Backend ECS security group"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "Backend from ALB"

    from_port = var.backend_port
    to_port   = var.backend_port

    protocol = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.app_name}-backend-sg"
  }
}

############################################
# DATABASE SECURITY GROUP
############################################

resource "aws_security_group" "database" {
  name = "${var.app_name}-db-sg"

  description = "RDS PostgreSQL security group"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "PostgreSQL from backend"

    from_port = 5432
    to_port   = 5432

    protocol = "tcp"

    security_groups = [
      aws_security_group.backend.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.app_name}-db-sg"
  }
}

############################################
# ECR FRONTEND
############################################

resource "aws_ecr_repository" "frontend" {
  name = "${var.app_name}-frontend"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.app_name}-frontend"
    Environment = var.environment
  }
}

############################################
# ECR BACKEND
############################################

resource "aws_ecr_repository" "backend" {
  name = "${var.app_name}-backend"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.app_name}-backend"
    Environment = var.environment
  }
}

############################################
# ECR FRONTEND LIFECYCLE
############################################

resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = aws_ecr_repository.frontend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1

        description = "Keep last 10 images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

############################################
# ECR BACKEND LIFECYCLE
############################################

resource "aws_ecr_lifecycle_policy" "backend" {
  repository = aws_ecr_repository.backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1

        description = "Keep last 10 images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

############################################
# CLOUDWATCH FRONTEND
############################################

resource "aws_cloudwatch_log_group" "frontend" {
  name = "/ecs/${var.app_name}/frontend"

  retention_in_days = 7
}

############################################
# CLOUDWATCH BACKEND
############################################

resource "aws_cloudwatch_log_group" "backend" {
  name = "/ecs/${var.app_name}/backend"

  retention_in_days = 7
}

############################################
# ECS CLUSTER
############################################

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.app_name}-cluster"
    Environment = var.environment
  }
}

############################################
# ECS EXECUTION ROLE
############################################

resource "aws_iam_role" "ecs_execution" {
  name = "${var.app_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

############################################
# ECS EXECUTION POLICY
############################################

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role = aws_iam_role.ecs_execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

############################################
# ECS TASK ROLE
############################################

resource "aws_iam_role" "ecs_task" {
  name = "${var.app_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

############################################
# RDS SUBNET GROUP
############################################

resource "aws_db_subnet_group" "postgres" {
  name = "${var.app_name}-db-subnet-group"

  subnet_ids = aws_subnet.private_db[*].id

  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

############################################
# RDS POSTGRESQL
############################################

resource "aws_db_instance" "postgres" {
  identifier = "${var.app_name}-postgres"

  engine         = "postgres"
  engine_version = var.postgres_version
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 20
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  port = 5432

  db_subnet_group_name = aws_db_subnet_group.postgres.name

  vpc_security_group_ids = [
    aws_security_group.database.id
  ]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 7

  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately   = true

  tags = {
    Name        = "${var.app_name}-postgres"
    Environment = var.environment
  }
}

############################################
# APPLICATION LOAD BALANCER
############################################

resource "aws_lb" "main" {
  name = "${var.app_name}-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.environment
  }
}

############################################
# FRONTEND TARGET GROUP
############################################

resource "aws_lb_target_group" "frontend" {
  name = "${var.app_name}-frontend-tg"

  port = var.frontend_port

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = aws_vpc.main.id

  health_check {
    path = var.frontend_health_path

    protocol = "HTTP"

    port = "traffic-port"

    healthy_threshold = 2

    unhealthy_threshold = 3

    timeout = 5

    interval = 30

    matcher = "200-399"
  }
}

############################################
# BACKEND TARGET GROUP
############################################

resource "aws_lb_target_group" "backend" {
  name = "${var.app_name}-backend-tg"

  port = var.backend_port

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = aws_vpc.main.id

  health_check {
    path = var.backend_health_path

    protocol = "HTTP"

    port = "traffic-port"

    healthy_threshold = 2

    unhealthy_threshold = 3

    timeout = 5

    interval = 30

    matcher = "200-399"
  }
}

############################################
# ALB LISTENER
############################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn

  port = 80

  protocol = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

############################################
# BACKEND PATH RULE
############################################

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.http.arn

  priority = 10

  action {
    type = "forward"

    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = [
        "/api",
        "/api/*"
      ]
    }
  }
}

############################################
# FRONTEND ECS TASK DEFINITION
############################################

resource "aws_ecs_task_definition" "frontend" {
  family = "${var.app_name}-frontend"

  network_mode = "awsvpc"

  requires_compatibilities = [
    "FARGATE"
  ]

  cpu = var.frontend_cpu

  memory = var.frontend_memory

  execution_role_arn = aws_iam_role.ecs_execution.arn

  task_role_arn = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name = "frontend"

      image = var.frontend_image

      essential = true

      portMappings = [
        {
          containerPort = var.frontend_port
          hostPort      = var.frontend_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NEXT_PUBLIC_API_URL"
          value = "/api"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "frontend"
        }
      }
    }
  ])
}

############################################
# BACKEND ECS TASK DEFINITION
############################################

resource "aws_ecs_task_definition" "backend" {
  family = "${var.app_name}-backend"

  network_mode = "awsvpc"

  requires_compatibilities = [
    "FARGATE"
  ]

  cpu = var.backend_cpu

  memory = var.backend_memory

  execution_role_arn = aws_iam_role.ecs_execution.arn

  task_role_arn = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name = "backend"

      image = var.backend_image

      essential = true

      portMappings = [
        {
          containerPort = var.backend_port
          hostPort      = var.backend_port
          protocol      = "tcp"
        }
      ]

      ########################################
      # APPLICATION ENVIRONMENT VARIABLES
      ########################################

      environment = [
        {
          name  = "PORT"
          value = tostring(var.backend_port)
        },
        {
          name  = "DATABASE_URL"
          value = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.address}:5432/${var.db_name}"
        }
      ]

      ########################################
      # CLOUDWATCH LOGGING
      ########################################

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "backend"
        }
      }
    }
  ])

  depends_on = [
    aws_db_instance.postgres
  ]
}

############################################
# FRONTEND ECS SERVICE
############################################

resource "aws_ecs_service" "frontend" {
  name = "${var.app_name}-frontend"

  cluster = aws_ecs_cluster.main.id

  task_definition = aws_ecs_task_definition.frontend.arn

  desired_count = var.frontend_desired_count

  launch_type = "FARGATE"

  platform_version = "LATEST"

  deployment_minimum_healthy_percent = 100

  deployment_maximum_percent = 200

  health_check_grace_period_seconds = 120

  enable_execute_command = true

  network_configuration {
    subnets = aws_subnet.private_ecs[*].id

    security_groups = [
      aws_security_group.frontend.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn

    container_name = "frontend"

    container_port = var.frontend_port
  }

  deployment_circuit_breaker {
    enable = true

    rollback = true
  }

  depends_on = [
    aws_lb_listener.http,
    aws_nat_gateway.main
  ]
}

############################################
# BACKEND ECS SERVICE
############################################

resource "aws_ecs_service" "backend" {
  name = "${var.app_name}-backend"

  cluster = aws_ecs_cluster.main.id

  task_definition = aws_ecs_task_definition.backend.arn

  desired_count = var.backend_desired_count

  launch_type = "FARGATE"

  platform_version = "LATEST"

  deployment_minimum_healthy_percent = 100

  deployment_maximum_percent = 200

  health_check_grace_period_seconds = 120

  enable_execute_command = true

  network_configuration {
    subnets = aws_subnet.private_ecs[*].id

    security_groups = [
      aws_security_group.backend.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn

    container_name = "backend"

    container_port = var.backend_port
  }

  deployment_circuit_breaker {
    enable = true

    rollback = true
  }

  depends_on = [
    aws_lb_listener_rule.backend,
    aws_nat_gateway.main,
    aws_db_instance.postgres
  ]
}
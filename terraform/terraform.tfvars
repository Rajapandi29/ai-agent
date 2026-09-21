aws_region  = "us-east-1"
app_name    = "ai-agent"
environment = "production"


vpc_cidr = "10.60.0.0/16"

azs = [
  "us-east-1a",
  "us-east-1b"
]

public_subnet_cidrs = [
  "10.60.1.0/24",
  "10.60.2.0/24"
]

private_ecs_subnet_cidrs = [
  "10.60.11.0/24",
  "10.60.12.0/24"
]

private_db_subnet_cidrs = [
  "10.60.21.0/24",
  "10.60.22.0/24"
]


frontend_port = 3000

frontend_health_path = "/"

frontend_cpu = 512

frontend_memory = 1024

frontend_desired_count = 1


backend_port = 8000

backend_health_path = "/health"

backend_cpu = 1024

backend_memory = 2048

backend_desired_count = 1


postgres_version = "17.6"

db_instance_class = "db.t4g.micro"

db_name = "aiagent"

db_username = "aiagentadmin"

db_password = "6321613#Rp"


frontend_image = "public.ecr.aws/docker/library/node:20-alpine"

backend_image = "public.ecr.aws/docker/library/python:3.11-slim"
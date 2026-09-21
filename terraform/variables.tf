variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "app_name" {
  type    = string
  default = "ai-agent"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "vpc_cidr" {
  type    = string
  default = "10.60.0.0/16"
}

variable "azs" {
  type = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "public_subnet_cidrs" {
  type = list(string)

  default = [
    "10.60.1.0/24",
    "10.60.2.0/24"
  ]
}

variable "private_ecs_subnet_cidrs" {
  type = list(string)

  default = [
    "10.60.11.0/24",
    "10.60.12.0/24"
  ]
}

variable "private_db_subnet_cidrs" {
  type = list(string)

  default = [
    "10.60.21.0/24",
    "10.60.22.0/24"
  ]
}


variable "frontend_port" {
  type    = number
  default = 3000
}

variable "frontend_health_path" {
  type    = string
  default = "/"
}

variable "frontend_cpu" {
  type    = number
  default = 512
}

variable "frontend_memory" {
  type    = number
  default = 1024
}

variable "frontend_desired_count" {
  type    = number
  default = 1
}

variable "backend_port" {
  type    = number
  default = 8000
}

variable "backend_health_path" {
  type    = string
  default = "/health"
}

variable "backend_cpu" {
  type    = number
  default = 1024
}

variable "backend_memory" {
  type    = number
  default = 2048
}

variable "backend_desired_count" {
  type    = number
  default = 1
}


variable "frontend_image" {
  type = string
}

variable "backend_image" {
  type = string
}
variable "postgres_version" {
  type    = string
  default = "17.6"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_name" {
  type    = string
  default = "aiagent"
}
variable "db_username" {
  type    = string
  default = "aiagentadmin"
}

variable "db_password" {
  type      = string
  sensitive = true
}
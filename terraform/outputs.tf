output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_ecs_subnet_ids" {
  value = aws_subnet.private_ecs[*].id
}

output "private_db_subnet_ids" {
  value = aws_subnet.private_db[*].id
}

output "frontend_ecr_repository_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "frontend_ecs_service_name" {
  value = aws_ecs_service.frontend.name
}

output "backend_ecs_service_name" {
  value = aws_ecs_service.backend.name
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "application_url" {
  value = "http://${aws_lb.main.dns_name}"
}

output "backend_url" {
  value = "http://${aws_lb.main.dns_name}/api"
}

output "database_endpoint" {
  value = aws_db_instance.postgres.address
}

output "database_port" {
  value = aws_db_instance.postgres.port
}

output "database_name" {
  value = aws_db_instance.postgres.db_name
}

output "database_username" {
  value = aws_db_instance.postgres.username
}

output "frontend_log_group" {
  value = aws_cloudwatch_log_group.frontend.name
}

output "backend_log_group" {
  value = aws_cloudwatch_log_group.backend.name
}
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

}
resource "aws_cloudwatch_log_group" "main" {
  name              = "/${var.project_name}/logs"
  retention_in_days = 14

  tags = { Name = "${var.project_name}-logs" }
}

# Pull Region for Task Definition
data "aws_region" "current" {}

#AWS Task definiton
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}_task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory


  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = var.app_image #Boostrap only, is gonna get overwritten by CICD
      essential = true

      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.main.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = { Name = "${var.project_name}-task" }
}


resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
 lifecycle {
    ignore_changes = [task_definition]
  }

  network_configuration {
    security_groups  = [var.ecs_sg]
    subnets          = var.ecs_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_tg
    container_name   = "${var.project_name}-container"
    container_port   = var.app_port

  }

  tags = { Name = "${var.project_name}-ecs-service" }
}
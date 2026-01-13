resource "aws_ecs_cluster" "main" {
 name = "${var.project_name}-cluster"

 setting {
    name  = "containerInsights"
    value = "enabled"
}

# Pull Region for Task Definition
data "aws_region" "current" {}

#AWS Task definiton
resource "aws_ecs_task_definition" "gatus_app" {
    family                   = "gatus_app_task"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_cpu
    memory                   = var.fargate_memory


    runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
    container_definitions = jsonencode([
    #Container Defintion - Acquired from Clickops
    {
      "cpu": 0,
      "environment": [],
      "environmentFiles": [],
      "essential": true,
      "readonlyRootFilesystem": true
      "image": "784607970889.dkr.ecr.eu-central-1.amazonaws.com/gatus-app@sha256:8d88dce86bb1c086d1ddeb14231b8aa97231c78bfab69669362d79467456727c",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/gatus-task-definition",
          "awslogs-create-group": "true",
          "awslogs-region": data.aws_region.current.region ,
          "awslogs-stream-prefix": "ecs"
        },
        "secretOptions": []
      },
      "mountPoints": [],
      "name": "gatus-app",
      "portMappings": [
        {
          "appProtocol": "http",
          "containerPort": 8080,
          "hostPort": 8080,
          "name": "gatus-app-8080-tcp",
          "protocol": "tcp"
        }
      ],
      "systemControls": [],
      "ulimits": [],
      "volumesFrom": []
    }

  ])
  tags = {Name = "${var.project_name}-task-definition"}
}

resource "aws_ecs_service" "main" {
    name            = "cb-service"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.gatus_app.arn
    desired_count   = var.app_count
    launch_type     = "FARGATE"
    assign_public_ip = false

    network_configuration {
        security_groups  = [var.ecs_sg]
        subnets          = var.ecs_subnets
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = var.alb_tg
        container_name   = "gatus-app"
        container_port   = var.app_port
        
    }

    depends_on = [  aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]

    tags = {Name = "${var.project_name}-ecs-service"}
}
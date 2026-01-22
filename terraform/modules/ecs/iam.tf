# IAM role required for ECS (Execution Role)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecstaskexecutionrole_gatus"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Attach AWS-managed execution role policy (ECR pull + logs write)
resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#allow creating the log group if it doesn't exist
resource "aws_iam_role_policy" "ecs_task_execution_logs_create_group" {
  name = "ecs-task-execution-logs-create-group"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup"
      ]
      Resource = "*"
    }]
  })
}
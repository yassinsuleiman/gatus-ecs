
# ALB security group (public)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.gatus_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS tasks security group (only ALB -> tasks)
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs-task-sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.gatus_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.alb_sg.id]

  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
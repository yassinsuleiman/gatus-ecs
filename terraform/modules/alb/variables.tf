variable "health_check_path" {
  type = string
}

variable "public_subnets" {
  type        = list(string)
  description = "Subnets in which the ECS Tasks will run"


}

variable "alb_sg" {
  description = "Security group for Load balancer"

}

variable "vpc_id" {
  type = string

}

variable "certificate_arn" {
  type = string

}
#network.tf
variable "az_count" {
  description = "Number of AZs to cover in a given region"
  type        = number

}
variable "my_vpc_cidr" {

  type = string

}


variable "app_port" {
  description = "Definition of first port protocol"
  default     = "8080"
}


variable "project_name" {
  type        = string
  description = "Dynamic naming of ressources by project name"

}

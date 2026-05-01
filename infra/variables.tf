variable "project_name" {
  type    = string
  default = "tasky-lab"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2c"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "public_key_path" {
  type = string
}

variable "mongo_instance_type" {
  type    = string
  default = "t3.small"
}

variable "mongo_admin_user" {
  type    = string
  default = "taskyadmin"
}

variable "mongo_admin_password" {
  type      = string
  sensitive = true
}

variable "mongo_app_user" {
  type    = string
  default = "taskyappuser"
}

variable "mongo_app_password" {
  type      = string
  sensitive = true
}

variable "tasky_secret_key" {
  type      = string
  sensitive = true
}

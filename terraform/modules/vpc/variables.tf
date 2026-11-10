variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "172.31.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["172.31.0.0/20", "172.31.16.0/20"]
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones for subnets"
}

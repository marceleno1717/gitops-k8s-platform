variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "project_name" {
  type    = string
  default = "ivolve-k8s"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "vpc_cidr" {
  type    = string
  default = "172.31.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["172.31.0.0/20", "172.31.16.0/20"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-3a", "eu-west-3b"]
}

variable "admin_ssh_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "key_name" {
  type        = string
  description = "AWS EC2 Key Pair name"
  default     = "k3s"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Local path to private key for Ansible inventory"
  default     = "~/.ssh/k3s.pem"
}

variable "master_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "worker_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "worker_count" {
  type    = number
  default = 1
}

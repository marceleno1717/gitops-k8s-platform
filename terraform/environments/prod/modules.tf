module "vpc" {
  source              = "../../modules/vpc"
  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
}

module "security" {
  source          = "../../modules/security"
  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = var.vpc_cidr
  admin_ssh_cidrs = var.admin_ssh_cidrs
}

module "compute" {
  source               = "../../modules/compute"
  project_name         = var.project_name
  environment          = var.environment
  subnet_id            = module.vpc.public_subnet_ids[0]
  security_group_id    = module.security.k8s_nodes_sg_id
  key_name             = var.key_name
  master_instance_type = var.master_instance_type
  worker_instance_type = var.worker_instance_type
  worker_count         = var.worker_count
}

# Automatically wait for cloud-init and execute the Ansible cluster bootstrapping playbook via dynamic EC2 inventory
resource "null_resource" "ansible_provisioner" {
  depends_on = [
    module.compute
  ]

  # Trigger re-execution if instance IPs change
  triggers = {
    master_ip  = module.compute.master_public_ip
    worker_ips = join(",", module.compute.worker_public_ips)
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting 60 seconds for cloud instances SSH and cloud-init to become fully ready..."
      sleep 60
      cd ${path.module}/../../../ansible
      ansible-playbook -i inventory.aws_ec2.yaml cluster-setup.yml --private-key ${var.ssh_private_key_path}
    EOT
  }
}

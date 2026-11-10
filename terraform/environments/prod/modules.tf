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

# Auto-generate dynamic Ansible inventory file (named 'inventory')
resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../../../ansible/inventory"
  file_permission = "0644"
  content         = <<-EOT
[master]
${module.compute.master_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.ssh_private_key_path} internal_ip=${module.compute.master_private_ip}

[workers]
%{ for index, ip in module.compute.worker_public_ips ~}
${ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.ssh_private_key_path} internal_ip=${module.compute.worker_private_ips[index]}
%{ endfor ~}

[k8s_cluster:children]
master
workers
EOT
}

# Automatically wait for SSH and execute the Ansible cluster bootstrapping playbook
resource "null_resource" "ansible_provisioner" {
  depends_on = [
    local_file.ansible_inventory,
    module.compute
  ]

  # Trigger re-execution if instances or inventory content changes
  triggers = {
    master_ip    = module.compute.master_public_ip
    worker_ips   = join(",", module.compute.worker_public_ips)
    inventory_id = local_file.ansible_inventory.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting 60 seconds for cloud instances SSH and cloud-init to become fully ready..."
      sleep 60
      cd ${path.module}/../../../ansible
      ansible-playbook -i inventory cluster-setup.yml
    EOT
  }
}

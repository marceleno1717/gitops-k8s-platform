output "vpc_id" {
  value = module.vpc.vpc_id
}

output "master_public_ip" {
  value = module.compute.master_public_ip
}

output "master_private_ip" {
  value = module.compute.master_private_ip
}

output "worker_public_ips" {
  value = module.compute.worker_public_ips
}

output "worker_private_ips" {
  value = module.compute.worker_private_ips
}

output "ansible_inventory_path" {
  value = local_file.ansible_inventory.filename
}

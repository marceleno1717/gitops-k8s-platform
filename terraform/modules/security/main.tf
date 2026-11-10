# Security group for Kubernetes control-plane and worker nodes
resource "aws_security_group" "k8s_nodes" {
  name        = "${var.project_name}-k8s-nodes-sg"
  description = "Security group for Kubernetes control-plane and worker nodes"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_ssh_cidrs
  }

  # Kubernetes API Server
  ingress {
    description = "Kubernetes API server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort Services
  ingress {
    description = "Kubernetes NodePort services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Calico BGP (Border Gateway Protocol)
  ingress {
    description = "Calico networking BGP"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Calico IP-in-IP
  ingress {
    description = "Calico IP-in-IP tunnel networking"
    from_port   = 0
    to_port     = 0
    protocol    = "4" # IP-in-IP protocol number
    cidr_blocks = [var.vpc_cidr]
  }

  # Calico VXLAN (alternative overlay)
  ingress {
    description = "Calico VXLAN networking"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Internal intra-cluster traffic (all protocols between nodes in VPC)
  ingress {
    description = "Allow all traffic within VPC for CNI and pod communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # Outbound Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-k8s-nodes-sg"
    Environment = var.environment
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    kubernetes = { 
        source = "hashicorp/kubernetes"
        version = "~> 1.9"
    }

    helm = {
        source = "hashicorp/helm"
        version = "~> 2.1.0"
    }
    
  }

    backend "s3" {
    bucket = "sre-challenge-davismar98"
    key    = "terraform"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC for the EKS Cluster
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.project
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Project = var.project
    "kubernetes.io/cluster/${var.project}" = "shared"
  }
}

# Create the EKS Cluster
module "eks-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.project
  cluster_version = var.eks_cluster_version
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    eks_nodes = {
      desired_capacity = var.eks_node_capacity
      max_capacity     = var.eks_node_capacity_max
      min_capaicty     = var.eks_node_capacity
      instance_type = var.eks_node_type
    }
  }

#   worker_groups = [
#     {
#       instance_type = var.eks_node_type
#       asg_max_size  = var.eks_node_capacity
#     }
#   ]

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  depends_on = [
    module.vpc
  ]

}

data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

# Create application environments

resource "kubernetes_namespace" "main" {
  for_each = toset(var.app_environments)
  metadata {
    annotations = {
      terraform_managed = "true"
    }

    labels = {
      app = var.app_name
    }

    name = each.value
  }

  depends_on = [
    module.eks-cluster
  ]
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Deploying Prometheus in the cluster
resource "helm_release" "prometheus" {
  name       = "${var.project}-prometheus"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = "monitoring"
  
}

# Deploying Grafana in the cluster
resource "helm_release" "grafana" {
  name       = "${var.project}-grafana"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
  
  values = [
    file("grafana.yml")
  ]

  set {
    name  = "persistence.storageClassName"
    value = "gp2"
  }
  set {
    name  = "persistence.enabled"
    value = true
  }
  set {
    name  = "adminPassword"
    value = "admin" #TODO: set in a secure way
  }
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }


}
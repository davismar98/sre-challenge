output "vpc-id" {
    value = module.vpc.vpc_id
}

output "cluster-endpoint" {
    value = module.eks-cluster.cluster_endpoint
}
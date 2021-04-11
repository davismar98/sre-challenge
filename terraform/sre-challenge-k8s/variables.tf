variable "project" {
  type        = string
  default     = "sre-challenge"
  description = "The project name that will be used to name and tag resources."
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The region where all the resources will be created."
}

variable "subnet_numbers" {
  description = "Map from availability zone to the number that should be used for each availability zone's subnet"
  default     = {
    "us-east-1a" = 1
    "us-east-1b" = 2
    "us-east-1c" = 3
  }
}

variable "eks_cluster_version" {
    type        = string 
    default     = "1.19"
    description = "Version of the EKS cluster"
}
variable "eks_node_capacity" {
  type        = number
  default     = 1
  description = "Number of managed nodes for the EKS cluster"
}

variable "eks_node_type" {
  type        = string
  default     = "m4.large"
  description = "Instance type for the managed EKS nodes"
}

# Kubernetes relates variables

variable "app_name" {
    type = string 
    default = "api-sre-challenge"
    description = "The name of the application"
}

variable "app_environments" {
  type = list(string)
  default = ["develop", "stage", "production"]
  description = "List of environments to be created as namespaces in the Cluster for the application"
}


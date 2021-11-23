#---------------------------------------------------------#
# EKS CLUSTER CORE VARIABLES
#---------------------------------------------------------#
#Following fields used in tagging resources and building the name of the cluster
#e.g., eks cluster name will be {tenant}-{environment}-{zone}-{resource}
#---------------------------------------------------------#
org               = "fis"     # Organization Name. Used to tag resources
tenant            = "sandbox"  # AWS account name or unique id for tenant
environment       = "preprod" # Environment area eg., preprod or prod
zone              = "dev"     # Environment with in one sub_tenant or business unit
terraform_version = "Terraform v1.0.7"

#---------------------------------------------------------#
# VPC and PRIVATE SUBNET DETAILS for EKS Cluster
#---------------------------------------------------------#
#This provides two options Option1 and Option2. You should choose either of one to provide VPC details to the EKS cluster
#Option1: Creates a new VPC, private Subnets and VPC Endpoints by taking the inputs of vpc_cidr_block and private_subnets_cidr. VPC Endpoints are S3, SSM , EC2, ECR API, ECR DKR, KMS, CloudWatch Logs, STS, Elastic Load Balancing, Autoscaling
#Option2: Provide an existing vpc_id and private_subnet_ids

#---------------------------------------------------------#
# OPTION 1
#---------------------------------------------------------#
create_vpc             = true
enable_private_subnets = true
enable_public_subnets  = true

# Enable or Disable NAT Gateway and Internet Gateway for Public Subnets
enable_nat_gateway = true
single_nat_gateway = true
create_igw         = true

vpc_cidr       = "10.1.0.0/16"
# aws-vpc.tf will split the vpc_cidr block to private and public cidrs across all
# available AZs in specific region. Consider setting and using the following variables
# for the explicit control over IP ranges in private and public subnets:

#private_subnets_cidr = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
#public_subnets_cidr  = ["10.1.12.0/22", "10.1.16.0/22", "10.1.20.0/22"]

# Change this to true when you want to create VPC endpoints for Private subnets
create_vpc_endpoints = true
#---------------------------------------------------------#
# OPTION 2
#---------------------------------------------------------#
//create_vpc = false
//vpc_id = "xxxxxx"
//private_subnet_ids = ['xxxxxx','xxxxxx','xxxxxx']

#---------------------------------------------------------#

#---------------------------------------------------------#
# EKS CONTROL PLANE VARIABLES
# API server endpoint access options
#   Endpoint public access: true    - Your cluster API server is accessible from the internet. You can, optionally, limit the CIDR blocks that can access the public endpoint.
#   Endpoint private access: true   - Kubernetes API requests within your cluster's VPC (such as node to control plane communication) use the private VPC endpoint.
#---------------------------------------------------------#
create_eks              = true
kubernetes_version      = "1.21"
endpoint_private_access = true
endpoint_public_access  = true

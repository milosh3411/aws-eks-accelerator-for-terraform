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
#This provides two options Option1 (for Sandbox) and Option2 (for Dev). You should choose either of one to provide VPC details to the EKS cluster
#Option1: Creates a new VPC, private Subnets and VPC Endpoints by taking the inputs of vpc_cidr_block and private_subnets_cidr. VPC Endpoints are S3, SSM , EC2, ECR API, ECR DKR, KMS, CloudWatch Logs, STS, Elastic Load Balancing, Autoscaling
#Option2: Use an existing vpc_id and private_subnet_ids created by FCS and create VPC endpoints

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
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = true

# Enable IAM Roles for Service Accounts (IRSA) on the EKS cluster
enable_irsa = true

enabled_cluster_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_period = 7

# EKS managed addons

enable_vpc_cni_addon  = true
vpc_cni_addon_version = "v1.8.0-eksbuild.1"

enable_coredns_addon  = true
coredns_addon_version = "v1.8.3-eksbuild.1"

enable_kube_proxy_addon  = true
kube_proxy_addon_version = "v1.20.4-eksbuild.2"

#------------------------------------------------#

  #---------------------------------------------------------#
  # EKS WORKER NODE GROUPS
  # Define Node groups as map of maps object as shown below. Each node group creates the following
  #    1. New node group
  #    2. IAM role and policies for Node group
  #    3. Security Group for Node group (Optional)
  #    4. Launch Templates for Node group   (Optional)
  #---------------------------------------------------------#
  enable_managed_nodegroups = true
  managed_node_groups = {
    #---------------------------------------------------------#
    # ON-DEMAND Worker Group - Worker Group - 1
    #---------------------------------------------------------#
    mg_4 = {
      # 1> Node Group configuration - Part1
      node_group_name        = "managed-ondemand" # Max 40 characters for node group name
      create_launch_template = true               # false will use the default launch template
      launch_template_os     = "amazonlinux2eks"  # amazonlinux2eks or bottlerocket
      public_ip              = false              # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata           = <<-EOT
            yum install -y amazon-ssm-agent
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent"
        EOT
      # 2> Node Group scaling configuration
      desired_size    = 3
      max_size        = 3
      min_size        = 3
      max_unavailable = 1 # or percentage = 20

      # 3> Node Group compute configuration
      ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
      capacity_type  = "ON_DEMAND"  # ON_DEMAND or SPOT
      instance_types = ["m4.large"] # List of instances used only for SPOT type
      disk_size      = 50

      # 4> Node Group network configuration
      subnet_ids = module.aws_vpc.private_subnets # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = []

      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        WorkerType  = "ON_DEMAND"
      }
      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }

      create_worker_security_group = true

    },
    #---------------------------------------------------------#
    # SPOT Worker Group - Worker Group - 2
    #---------------------------------------------------------#
    /*
    spot_m5 = {
      # 1> Node Group configuration - Part1
      node_group_name        = "managed-spot-m5"
      create_launch_template = true              # false will use the default launch template
      launch_template_os        = "amazonlinux2eks" # amazonlinux2eks  or bottlerocket
      public_ip              = false             # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata           = <<-EOT
                 yum install -y amazon-ssm-agent
                 systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent"
             EOT

      # Node Group scaling configuration
      desired_size = 3
      max_size     = 3
      min_size     = 3

      # Node Group update configuration. Set the maximum number or percentage of unavailable nodes to be tolerated during the node group version update.
      max_unavailable = 1 # or percentage = 20

      # Node Group compute configuration
      ami_type       = "AL2_x86_64"
      capacity_type  = "SPOT"
      instance_types = ["t3.medium", "t3a.medium"]
      disk_size      = 50

      # Node Group network configuration

      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = []

      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        WorkerType  = "SPOT"
      }
      additional_tags = {
        ExtraTag    = "spot_nodes"
        Name        = "spot"
        subnet_type = "private"
      }

      create_worker_security_group = false
    },

    #---------------------------------------------------------#
    # BOTTLEROCKET - Worker Group - 3
    #---------------------------------------------------------#
    brkt_m5 = {
      node_group_name        = "managed-brkt-m5"
      create_launch_template = true           # false will use the default launch template
      launch_template_os        = "bottlerocket" # amazonlinux2eks  or bottlerocket
      public_ip              = false          # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata           = ""

      desired_size    = 3
      max_size        = 3
      min_size        = 3
      max_unavailable = 1

      ami_type       = "CUSTOM"
      capacity_type  = "ON_DEMAND" # ON_DEMAND or SPOT
      instance_types = ["m5.large"]
      disk_size      = 50
      custom_ami_id  = "ami-044b114caf98ce8c5" # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami-bottlerocket.html

      # Node Group network configuration

      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = {}
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        OS          = "bottlerocket"
        WorkerType  = "ON_DEMAND_BOTTLEROCKET"
      }
      additional_tags = {
        ExtraTag = "bottlerocket"
        Name     = "bottlerocket"
      }
      #security_group ID
      create_worker_security_group = true
    }

      */
  } # END OF MANAGED NODE GROUPS

  #---------------------------------------------------------#
  # EKS SELF MANAGED WORKER NODE GROUPS
  #---------------------------------------------------------#

  enable_windows_support = false

  enable_self_managed_nodegroups = false

  self_managed_node_groups = {
    #---------------------------------------------------------#
    # ON-DEMAND Self Managed Worker Group - Worker Group - 1
    #---------------------------------------------------------#
    self_mg_4 = {
      node_group_name        = "self-managed-ondemand" # Name is used to create a dedicated IAM role for each node group and adds to AWS-AUTH config map
      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
      custom_ami_id          = "ami-0dfaa019a300f219c" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
      public_ip              = false                   # Enable only for public subnets
      pre_userdata           = <<-EOT
            yum install -y amazon-ssm-agent \
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent \
        EOT

      disk_size     = 20
      instance_type = "m5.large"

      desired_size = 2
      max_size     = 10
      min_size     = 2

      capacity_type = "" # Optional Use this only for SPOT capacity as  capacity_type = "spot"

      k8s_labels = {
        Environment = "preprod"
        Zone        = "test"
        WorkerType  = "SELF_MANAGED_ON_DEMAND"
      }

      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }


      subnet_ids = [] # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      create_worker_security_group = false # Creates a dedicated sec group for this Node Group
    },
    /*
    spot_m5 = {
      # 1> Node Group configuration - Part1
      node_group_name = "self-managed-spot"
      create_launch_template = true
      launch_template_os = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
      custom_ami_id   = "ami-0dfaa019a300f219c" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
      public_ip       = false                   # Enable only for public subnets
      pre_userdata    = <<-EOT
              yum install -y amazon-ssm-agent \
              systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent \
          EOT

      disk_size     = 20
      instance_type = "m5.large"

      desired_size = 2
      max_size     = 10
      min_size     = 2

      capacity_type = "spot"

      # Node Group network configuration

      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = []
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        WorkerType  = "SPOT"
      }
      additional_tags = {
        ExtraTag    = "spot_nodes"
        Name        = "spot"
        subnet_type = "private"
      }

      create_worker_security_group = false
    },

    brkt_m5 = {
      node_group_name = "self-managed-brkt"
      create_launch_template = true
      launch_template_os = "bottlerocket"          # amazonlinux2eks  or bottlerocket or windows
      custom_ami_id   = "ami-044b114caf98ce8c5" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
      public_ip       = false                   # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata    = ""

      desired_size    = 3
      max_size        = 3
      min_size        = 3
      max_unavailable = 1

      instance_types = "m5.large"
      disk_size      = 50


      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = []

      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        OS          = "bottlerocket"
        WorkerType  = "ON_DEMAND_BOTTLEROCKET"
      }
      additional_tags = {
        ExtraTag = "bottlerocket"
        Name     = "bottlerocket"
      }

      create_worker_security_group = true
    }

    #---------------------------------------------------------#
    # ON-DEMAND Self Managed Windows Worker Node Group
    #---------------------------------------------------------#
    windows_od = {
      node_group_name = "windows-ondemand"
      create_launch_template = true
      launch_template_os = "windows"          # amazonlinux2eks  or bottlerocket or windows
      # custom_ami_id   = "ami-xxxxxxxxxxxxxxxx" # Bring your own custom AMI. Default Windows AMI is the latest EKS Optimized Windows Server 2019 English Core AMI.
      public_ip = false # Enable only for public subnets

      disk_size     = 50
      instance_type = "m5n.large"

      desired_size = 2
      max_size     = 4
      min_size     = 2

      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        WorkerType  = "WINDOWS_ON_DEMAND"
      }

      additional_tags = {
        ExtraTag    = "windows-on-demand"
        Name        = "windows-on-demand"

      }

      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      create_worker_security_group = false # Creates a dedicated sec group for this Node Group
    }
  */
  } # END OF SELF MANAGED NODE GROUPS


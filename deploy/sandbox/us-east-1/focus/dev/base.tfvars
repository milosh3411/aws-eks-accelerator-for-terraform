#---------------------------------------------------------#
# EKS CLUSTER CORE VARIABLES
#---------------------------------------------------------#
#Following fields used in tagging resources and building the name of the cluster
#---------------------------------------------------------#

/*** FIS default tags **/
buc               = "4012.523420.9820..0000.0000.3117"
support_group     = "Ambit Risk EMEA"
app_group_email   = "AmbitRisk.EMEA.Help@fisglobal.com"
environment_type  = "dev"
customer_crmid    = "FIS 6015"
org               = "ambit"
application       = "focus"
zone              = "sandbox"
terraform_version = "Terraform v1.0.7"

/*** EC2 tags     ***/
expiration_date     = "Never"
solution_central_id = "15589"
sla                 = "99.5"
maintenance_window  = "[*/*/*/*/0]"
tier                = "System"
on_hours            = "Always"

#---------------------------------------------------------#
# VPC and PRIVATE SUBNET DETAILS for EKS Cluster
#---------------------------------------------------------#

create_vpc_endpoints = true

# !!!Environment specific!!! (sandbox vs sdl):
vpc_id             = "vpc-0e79e14348f9b9631"
private_subnet_ids = ["subnet-0e31166d8a08c3b71", "subnet-0310c6de0f502c262"]
#public_subnet_ids = []



route_table_ids = ["rtb-017d17e1cd14706e7"]

#---------------------------------------------------------#

#---------------------------------------------------------#
# EKS CONTROL PLANE VARIABLES
# API server endpoint access options
#   Endpoint public access: true    - Your cluster API server is accessible from the internet. You can, optionally, limit the CIDR blocks that can access the public endpoint.
#   Endpoint private access: true   - Kubernetes API requests within your cluster's VPC (such as node to control plane communication) use the private VPC endpoint.
#---------------------------------------------------------#
create_eks                      = true
kubernetes_version              = "1.21"
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = true

# Enable IAM Roles for Service Accounts (IRSA) on the EKS cluster
enable_irsa = true


# EKS cluster logs
cluster_enabled_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_period = 7

# EKS managed addons (these are managed by AWS, other addons need to be deployed by helm charts)

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
    desired_size    = 2
    max_size        = 2
    min_size        = 2
    max_unavailable = 1 # or percentage = 20

    # 3> Node Group compute configuration
    ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
    capacity_type  = "ON_DEMAND"  # ON_DEMAND or SPOT
    instance_types = ["m4.large"] # List of instances used only for SPOT type
    disk_size      = 50

    # 4> Node Group network configuration
    # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']
    # subnet_ids  = []

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

  }
} # END OF MANAGED NODE GROUPS

#---------------------------------------------------------#
# EKS SELF MANAGED WORKER NODE GROUPS
#---------------------------------------------------------#

enable_windows_support = true

enable_self_managed_nodegroups = true

self_managed_node_groups = {
  #---------------------------------------------------------#
  # ON-DEMAND Self Managed Windows Worker Node Group
  #---------------------------------------------------------#
  windows_od = {
    node_group_name        = "windows-ondemand"
    create_launch_template = true
    launch_template_os     = "windows" # amazonlinux2eks  or bottlerocket or windows
    # custom_ami_id   = "ami-xxxxxxxxxxxxxxxx" # Bring your own custom AMI. Default Windows AMI is the latest EKS Optimized Windows Server 2019 English Core AMI.
    public_ip = false # Enable only for public subnets

    disk_size     = 50
    instance_type = "m5n.large"

    desired_size = 2
    max_size     = 2
    min_size     = 1

    k8s_labels = {
      Environment = "preprod"
      Zone        = "dev"
      WorkerType  = "WINDOWS_ON_DEMAND"
    }

    additional_tags = {
      ExtraTag = "windows-on-demand"
      Name     = "windows-on-demand"

    }
    # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']
    # subnet_ids  = []

    create_worker_security_group = false # Creates a dedicated sec group for this Node Group
  }
} # END OF SELF MANAGED NODE GROUPS


#-------EKS ADDONS----------------------
#---------------------------------------
# TRAEFIK INGRESS CONTROLLER HELM ADDON
#---------------------------------------
#  traefik_ingress_controller_enable = false
#
#  # Optional Map value
#  traefik_helm_chart = {
#    name       = "traefik"                         # (Required) Release name.
#    repository = "https://helm.traefik.io/traefik" # (Optional) Repository URL where to locate the requested chart.
#    chart      = "traefik"                         # (Required) Chart name to be installed.
#    version    = "10.0.0"                          # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
#    namespace  = "kube-system"                     # (Optional) The namespace to install the release into. Defaults to default
#    timeout    = "1200"                            # (Optional)
#    lint       = "true"                            # (Optional)
#    # (Optional) Example to show how to override values using SET
#    set = [{
#      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
#      value = "nlb"
#    }]
#    # (Optional) Example to show how to pass metrics-server-values.yaml
#    values = [templatefile("${path.module}/k8s_addons/traefik-values.yaml", {
#      operating_system = "linux"
#    })]
#  }
#
#  #---------------------------------------
#  # METRICS SERVER HELM ADDON
#  #---------------------------------------
#  metrics_server_enable = false
#
#  # Optional Map value
#  metrics_server_helm_chart = {
#    name       = "metrics-server"                                    # (Required) Release name.
#    repository = "https://kubernetes-sigs.github.io/metrics-server/" # (Optional) Repository URL where to locate the requested chart.
#    chart      = "metrics-server"                                    # (Required) Chart name to be installed.
#    version    = "3.5.0"                                             # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
#    namespace  = "kube-system"                                       # (Optional) The namespace to install the release into. Defaults to default
#    timeout    = "1200"                                              # (Optional)
#    lint       = "true"                                              # (Optional)
#
#    # (Optional) Example to show how to pass metrics-server-values.yaml
#    values = [templatefile("${path.module}/k8s_addons/metrics-server-values.yaml", {
#      operating_system = "linux"
#    })]
#  }
#
#  #---------------------------------------
#  # CLUSTER AUTOSCALER HELM ADDON
#  #---------------------------------------
#  cluster_autoscaler_enable = false
#
#  # Optional Map value
#  cluster_autoscaler_helm_chart = {
#    name       = "cluster-autoscaler"                      # (Required) Release name.
#    repository = "https://kubernetes.github.io/autoscaler" # (Optional) Repository URL where to locate the requested chart.
#    chart      = "cluster-autoscaler"                      # (Required) Chart name to be installed.
#    version    = "9.10.7"                                  # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
#    namespace  = "kube-system"                             # (Optional) The namespace to install the release into. Defaults to default
#    timeout    = "1200"                                    # (Optional)
#    lint       = "true"                                    # (Optional)
#
#    # (Optional) Example to show how to pass metrics-server-values.yaml
#    values = [templatefile("${path.module}/k8s_addons/cluster-autoscaler-vaues.yaml", {
#      operating_system = "linux"
#    })]
#  }
#
#  #---------------------------------------
#  # ENABLE NGINX
#  #---------------------------------------
#
#  nginx_ingress_controller_enable = false
#  # Optional nginx_helm_chart
#  nginx_helm_chart = {
#    name       = "ingress-nginx"
#    chart      = "ingress-nginx"
#    repository = "https://kubernetes.github.io/ingress-nginx"
#    version    = "3.33.0"
#    namespace  = "kube-system"
#    values     = [templatefile("${path.module}/k8s_addons/nginx-values.yaml", {})]
#  }
#

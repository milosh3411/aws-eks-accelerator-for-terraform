/*** FIS default Tags ***/
variable "buc" {
  description = "The Business Unit Code associated with the group responsible for the deployed asset."
  default     = "4010.523420.0000..0000.0000.0000"
}

variable "support_group" {
  description = "The name of the group responsible for the deployed asset."
  default     = "Ambit Operations"
}

variable "app_group_email" {
  description = "The email address for the operations team responsible for the deployed asset."
  default     = "Ambit.Ops.Support@fisglobal.com"
}

variable "environment_type" {
  description = "The tier of environment for the application -- this is separate from the service level defined at the subscription level."
  default     = "Dev"
}

variable "customer_crmid" {
  description = "The end customer of the system and the CRM ID of the end customer of the system."
  default     = ""
}

variable "org" {
  type        = string
  description = "your organization name, e.g. arp"
  default     = "arp"
}

variable "terraform_version" {
  type        = string
  default     = "Terraform"
  description = "Terraform Version"
}

variable "zone" {
  type        = string
  description = "e.g. 'sandbox', 'sdl', 'production'"
}

variable "application" {
  type        = string
  description = "Application name"
  default     = "focus"
}

/*** EC2 tags     ***/
variable "expiration_date" {
  default = "Never"
}

variable "solution_central_id" {
  default = "15589"
}

variable "sla" {
  default = "99.5"
}

variable "maintenance_window" {
  default = "*/*/*/*/0"
}

variable "tier" {
  default = "System"
}

variable "on_hours" {
  default = "Always"
}

/*** VPC variables ***/
variable "vpc_id" {
  type        = string
  description = "VPC id"
  default     = ""
}
variable "private_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  default     = []
}
variable "public_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  default     = []
}
variable "create_vpc_endpoints" {
  type        = bool
  default     = false
  description = "Create VPC endpoints for Private subnets"
}

variable "route_table_ids" {
  description = "VPC route table IDs, required for creation of S3 gateway endpoint"
  default     = []
}

# EKS CONTROL PLANE
variable "create_eks" {
  type        = bool
  default     = false
  description = "Enable Create EKS"
}
variable "kubernetes_version" {
  type        = string
  default     = "1.21"
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
}
variable "cluster_endpoint_private_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false"
}
variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
}
variable "enable_irsa" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
}
variable "cluster_enabled_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "A list of the desired control plane logging to enable"
}
variable "cluster_log_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain cluster logs"
}

# EKS MANAGED ADDONS
variable "enable_vpc_cni_addon" {
  type        = bool
  default     = false
  description = "Enable VPC CNI Addon"
}
variable "enable_coredns_addon" {
  type        = bool
  default     = false
  description = "Enable CoreDNS Addon"
}
variable "enable_kube_proxy_addon" {
  type        = bool
  default     = false
  description = "Enable Kube Proxy Addon"
}
variable "vpc_cni_addon_version" {
  type        = string
  default     = "v1.8.0-eksbuild.1"
  description = "VPC CNI Addon version"
}
variable "coredns_addon_version" {
  type        = string
  default     = "v1.8.3-eksbuild.1"
  description = "CoreDNS Addon version"
}
variable "kube_proxy_addon_version" {
  type        = string
  default     = "v1.20.4-eksbuild.2"
  description = "KubeProxy Addon version"
}

# EKS WORKER NODES
variable "enable_managed_nodegroups" {
  description = "Enable self-managed worker groups"
  type        = bool
  default     = false
}
variable "managed_node_groups" {
  description = "Managed Node groups configuration"
  type        = any
  default     = {}
}
variable "enable_self_managed_nodegroups" {
  description = "Enable self-managed worker groups"
  type        = bool
  default     = false
}
variable "self_managed_node_groups" {
  description = "Self-Managed Node groups configuration"
  type        = any
  default     = {}
}



# EKS WINDOWS SUPPORT
variable "enable_windows_support" {
  description = "Enable Windows support"
  type        = bool
  default     = false
}

# CONFIGMAP AWS-AUTH
variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. "
  type        = list(string)
  default     = []
}
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. "
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "aws_auth_additional_labels" {
  description = "Additional kubernetes labels applied on aws-auth ConfigMap"
  default     = {}
  type        = map(string)
}

# KUBERNETES ADDONS VARIABLES

#-----------CLUSTER AUTOSCALER-------------
variable "cluster_autoscaler_enable" {
  type        = bool
  default     = false
  description = "Enabling Cluster autoscaler on eks cluster"
}
variable "cluster_autoscaler_helm_chart" {
  type        = any
  default     = {}
  description = "Cluster Autoscaler Helm Chart Config"
}

#-----------METRIC SERVER-------------
variable "metrics_server_enable" {
  type        = bool
  default     = false
  description = "Enabling metrics server on eks cluster"
}
variable "metrics_server_helm_chart" {
  type        = any
  default     = {}
  description = "Metrics Server Helm Addon Config"
}
#-----------TRAEFIK-------------
variable "traefik_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "Enabling Traefik Ingress Controller on eks cluster"
}
variable "traefik_helm_chart" {
  type        = any
  default     = {}
  description = "Traefik Helm Addon Config"
}

#-----------AWS LB Ingress Controller-------------
variable "aws_lb_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "enabling LB Ingress Controller on eks cluster"
}
variable "aws_lb_ingress_controller_helm_app" {
  type        = any
  description = "Helm chart definition for aws_lb_ingress_controller"
  default     = {}
}
#-----------NGINX-------------
variable "nginx_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "Enabling NGINX Ingress Controller on EKS Cluster"
}
variable "nginx_helm_chart" {
  description = "NGINX Ingress Controller Helm Chart Configuration"
  type        = any
  default     = {}
}

#-----------CERT MANAGER-------------
variable "cert_manager_enable" {
  type        = bool
  default     = false
  description = "Enabling Cert Manager Helm Chart installation. It is automatically enabled if Windows support is enabled."
}
variable "cert_manager_helm_chart" {
  type        = any
  description = "Cert Manager Helm chart configuration"
  default     = {}
}
#------WINDOWS VPC CONTROLLERS-------------
variable "windows_vpc_controllers_helm_chart" {
  type        = any
  description = "Windows VPC Controllers Helm chart configuration"
  default     = {}
}

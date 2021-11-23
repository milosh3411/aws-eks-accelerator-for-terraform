variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = false
}
variable "enable_public_subnets" {
  description = "Enable public subnets for EKS Cluster"
  type        = bool
  default     = false
}
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for public subnets"
  type        = bool
  default     = false
}
variable "single_nat_gateway" {
  description = "Create single NAT gateway for all private subnets"
  type        = bool
  default     = true
}
variable "create_igw" {
  description = "Create internet gateway in public subnets"
  type        = bool
  default     = false
}
variable "enable_private_subnets" {
  description = "Enable private subnets for EKS Cluster"
  type        = bool
  default     = true
}

variable "vpc_cidr_block" {
  type        = string
  default     = ""
  description = "VPC CIDR"
}
variable "public_subnets_cidr" {
  description = "list of Public subnets for the Worker nodes"
  default     = []
}
variable "private_subnets_cidr" {
  description = "list of Private subnets for the Worker nodes"
  default     = []
}

variable "create_vpc_endpoints" {
  type        = bool
  default     = false
  description = "Create VPC endpoints for Private subnets"
}

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
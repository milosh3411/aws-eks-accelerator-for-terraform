locals {

  /*----------------------------------------------------------------*/
  //NAMING AND DEFAULT TAGS
  /*----------------------------------------------------------------*/

  name_prefix = join("-", [var.environment_type, var.org, var.application])
  default_tags = tomap({
    /* FIS default tags*/
    "BUC"             = var.buc
    "SupportGroup"    = var.support_group
    "AppGroupEmail"   = var.app_group_email
    "EnvironmentType" = var.environment_type
    "CustomerCRMID"   = var.customer_crmid
    /* ARP additional default tags*/
    "CreatedBy" = var.terraform_version
    "Zone"      = var.zone
  })

  /*----------------------------------------------------------------*/
  // RESOURCE SPECIFIC TAGS
  /*----------------------------------------------------------------*/

  ec2_tags = tomap({
    "SolutionCentralID" = var.solution_central_id
    "MaintenanceWindow" = var.maintenance_window
    "Tier"              = var.tier
    "SLA"               = var.sla
    "OnHours"           = var.on_hours
    "ExpirationDate"    = var.expiration_date
  })

  ecr_image_repo_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com"

  # Managed node IAM Roles for aws-auth
  managed_node_group_aws_auth_config_map = var.enable_managed_nodegroups == true ? [
    for key, node in var.managed_node_groups : {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}"
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ] : []

  # Self Managed node IAM Roles for aws-auth
  self_managed_node_group_aws_auth_config_map = var.enable_self_managed_nodegroups ? [
    for key, node in var.self_managed_node_groups : {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}"
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    } if node.launch_template_os != "windows"
  ] : []

  # Self Managed Windows node IAM Roles for aws-auth
  windows_node_group_aws_auth_config_map = var.enable_self_managed_nodegroups && var.enable_windows_support ? [
    for key, node in var.self_managed_node_groups : {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}"
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes",
        "eks:kube-proxy-windows"
      ]
    } if node.launch_template_os == "windows"
  ] : []

}

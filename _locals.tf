/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

locals {

  default_tags = tomap({
    "created-by"      = var.terraform_version
    "BUC"             = var.tag_buc
    "SupportGroup"    = var.tag_support_group
    "AppGroupEmail"   = var.tag_app_group_email
    "EnvironmentType" = var.tag_environment_type
    "CustomerCRMID"   = var.tag_customer_crmid
  })

  ec2_tags = tomap({
    "SolutionCentralID" = var.tag_solution_central_id
    "MaintenanceWindow" = var.tag_maintenance_window
    "Tier"              = var.tag_tier
    "SLA"               = var.tag_sla
    "OnHours"           = var.tag_on_hours
    "ExpirationDate"    = var.tag_on_hours
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

  # Fargate node IAM Roles for aws-auth
  fargate_profiles_aws_auth_config_map = var.enable_fargate == true ? [
    for key, node in var.fargate_profiles : {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${module.aws_eks.cluster_id}-${node.fargate_profile_name}"
      username : "system:node:{{SessionName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes",
        "system:node-proxier"
      ]
    }
  ] : []

  # EMR on EKS IAM Roles for aws-auth
  emr_on_eks_config_map = var.enable_emr_on_eks == true ? [
    {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/AWSServiceRoleForAmazonEMRContainers"
      username : "emr-containers"
      groups : []
    }
  ] : []

  service_account_amp_ingest_name = format("%s-%s", module.aws_eks.cluster_id, "amp-ingest")
  service_account_amp_query_name  = format("%s-%s", module.aws_eks.cluster_id, "amp-query")

  # Configuration for managing add-ons via GitOps.
  gitops_add_on_config = {
    awsForFluentBit = var.aws_for_fluentbit_enable ? module.aws_for_fluent_bit[0].gitops_config : null
  }
}

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

module "metrics_server" {
  count                     = var.create_eks && var.metrics_server_enable ? 1 : 0
  source                    = "./kubernetes-addons/metrics-server"
  metrics_server_helm_chart = var.metrics_server_helm_chart

  depends_on = [module.aws_eks]
}

module "cluster_autoscaler" {
  count                         = var.create_eks && var.cluster_autoscaler_enable ? 1 : 0
  source                        = "./kubernetes-addons/cluster-autoscaler"
  eks_cluster_id                = module.aws_eks.cluster_id
  cluster_autoscaler_helm_chart = var.cluster_autoscaler_helm_chart

  depends_on = [module.aws_eks]
}

module "traefik_ingress" {
  count              = var.create_eks && var.traefik_ingress_controller_enable ? 1 : 0
  source             = "./kubernetes-addons/traefik-ingress"
  traefik_helm_chart = var.traefik_helm_chart

  depends_on = [module.aws_eks]
}


module "aws_load_balancer_controller" {
  count                          = var.create_eks && var.aws_lb_ingress_controller_enable ? 1 : 0
  source                         = "./kubernetes-addons/aws-load-balancer-controller"
  eks_cluster_id                 = module.aws_eks.cluster_id
  lb_ingress_controller_helm_app = var.aws_lb_ingress_controller_helm_app
  eks_oidc_issuer_url            = module.aws_eks.cluster_oidc_issuer_url
  eks_oidc_provider_arn          = module.aws_eks.oidc_provider_arn

  depends_on = [module.aws_eks]
}

module "nginx_ingress" {
  count            = var.create_eks && var.nginx_ingress_controller_enable ? 1 : 0
  source           = "./kubernetes-addons/nginx-ingress"
  nginx_helm_chart = var.nginx_helm_chart

  depends_on = [module.aws_eks]
}

module "cert_manager" {
  count  = var.create_eks && (var.cert_manager_enable || var.enable_windows_support) ? 1 : 0
  source = "./kubernetes-addons/cert-manager"

  cert_manager_helm_chart = var.cert_manager_helm_chart

  depends_on = [module.aws_eks]
}

module "windows_vpc_controllers" {
  count  = var.create_eks && var.enable_windows_support ? 1 : 0
  source = "./kubernetes-addons/windows-vpc-controllers"

  windows_vpc_controllers_helm_chart = var.windows_vpc_controllers_helm_chart

  depends_on = [
    module.cert_manager, module.aws_eks
  ]
}



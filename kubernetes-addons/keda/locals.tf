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
  keda_service_account_name = "keda-sa"
  keda_namespace            = "keda-ns"

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    service_account_name = local.keda_service_account_name
  })]

  default_keda_helm_app = {
    name                       = "keda"
    chart                      = "keda"
    repository                 = "https://kedacore.github.io/charts"
    version                    = "2.4.0"
    namespace                  = "keda"
    timeout                    = "1200"
    create_namespace           = false
    description                = "Keda Event-based autoscaler for workloads on Kubernetes"
    lint                       = false
    wait                       = true
    wait_for_jobs              = false
    verify                     = false
    keyring                    = ""
    repository_key_file        = ""
    repository_cert_file       = ""
    repository_ca_file         = ""
    repository_username        = ""
    repository_password        = ""
    disable_webhooks           = false
    reuse_values               = false
    reset_values               = false
    force_update               = false
    recreate_pods              = false
    cleanup_on_fail            = false
    max_history                = 0
    atomic                     = false
    skip_crds                  = false
    render_subchart_notes      = true
    disable_openapi_validation = false
    dependency_update          = false
    replace                    = false
    postrender                 = ""
    set                        = []
    set_sensitive              = []
    values                     = local.default_helm_values
  }

  keda_helm_app = merge(
    local.default_keda_helm_app,
    var.keda_helm_chart
  )

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.keda_service_account_name
  }
}

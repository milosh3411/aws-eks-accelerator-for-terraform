module "endpoints_interface" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "v3.2.0"

  create = var.create_vpc_endpoints
  vpc_id = local.vpc_id

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc.intra_route_table_ids,
      module.vpc.private_route_table_ids])
      tags = { Name = "s3-vpc-Gateway" }
    },
    /*
    dynamodb = {
      service = "dynamodb"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc.intra_route_table_ids,
        module.vpc.private_route_table_ids,
        module.vpc.public_route_table_ids])
      policy = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      tags = { Name = "dynamodb-vpc-endpoint" }
    },
    */
  }
  depends_on = [module.aws_vpc]
}

module "vpc_endpoints_gateway" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "v3.2.0"

  create = var.create_vpc_endpoints

  vpc_id             = local.vpc_id
  security_group_ids = [data.aws_security_group.default.id]
  subnet_ids         = local.private_subnet_ids

  endpoints = {
    aps-workspaces = {
      service             = "aps-workspaces"
      private_dns_enabled = true
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
    },
    autoscaling = {
      service             = "autoscaling"
      private_dns_enabled = true
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
    },
    elasticloadbalancing = {
      service             = "elasticloadbalancing"
      private_dns_enabled = true
    },
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
    },
    kms = {
      service             = "kms"
      private_dns_enabled = true
    },
    /*    elasticfilesystem = {
          service             = "elasticfilesystem"
          private_dns_enabled = true
        },
        ssmmessages = {
          service             = "ssmmessages"
          private_dns_enabled = true
        },
        lambda = {
          service             = "lambda"
          private_dns_enabled = true
        },
        ecs = {
          service             = "ecs"
          private_dns_enabled = true
        },
        ecs_telemetry = {
          service             = "ecs-telemetry"
          private_dns_enabled = true
        },
        codedeploy = {
          service             = "codedeploy"
          private_dns_enabled = true
        },
        codedeploy_commands_secure = {
          service             = "codedeploy-commands-secure"
          private_dns_enabled = true
        },*/
  }

  tags = merge(local.default_tags, {
    Project  = "EKS"
    Endpoint = "true"
  })
  depends_on = [module.aws_vpc]
}

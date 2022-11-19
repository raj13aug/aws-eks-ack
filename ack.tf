###############################
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

################################

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_eks_cluster" "this" {
  name = local.cluster_id
}

locals {
  # this makes downstream resources wait for data plane to be ready
  cluster_id = var.cluster_name
  region     = var.aws_region

  eks_oidc_issuer_url = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")

  addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = data.aws_eks_cluster.this.endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = local.region
    eks_cluster_id                 = var.cluster_name
    eks_oidc_issuer_url            = local.eks_oidc_issuer_url
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
    tags                           = var.tags
    irsa_iam_role_path             = var.irsa_iam_role_path
    irsa_iam_permissions_boundary  = var.irsa_iam_permissions_boundary
  }
}


################################################################################
# S3
################################################################################

locals {
  s3_name = "ack-s3"
}

module "s3" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon?ref=v4.12.2"

  count = var.enable_s3 ? 1 : 0

  helm_config = merge(
    {
      name        = local.s3_name
      chart       = "s3-chart"
      repository  = "oci://public.ecr.aws/aws-controllers-k8s"
      version     = "v0.1.5"
      namespace   = local.s3_name
      description = "ACK S3 Controller v2 Helm chart deployment configuration"
      values = [
        <<-EOT
          nameOverride: ack-s3
        EOT
      ]
    },
    var.s3_helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.s3_name
    },
    {
      name  = "serviceAccount.create"
      value = false
    },
    {
      name  = "aws.region"
      value = "us-east-1"
    }
  ]

  irsa_config = {
    create_kubernetes_namespace = true
    kubernetes_namespace        = try(var.s3_helm_config.namespace, local.s3_name)

    create_kubernetes_service_account = true
    kubernetes_service_account        = local.s3_name

    irsa_iam_policies = [data.aws_iam_policy.s3[0].arn]
  }

  addon_context = local.addon_context
}

data "aws_iam_policy" "s3" {
  count = var.enable_s3 ? 1 : 0

  name = "AmazonS3FullAccess"
}
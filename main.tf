module "ack" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-ack.git?ref=0.1.1"

  enabled = true

  cluster_name                     = module.eks_cluster.cluster_id
  cluster_identity_oidc_issuer     = module.eks_cluster.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks_cluster.oidc_provider_arn
  aws_region                       = data.aws_region.current.name

  helm_services = [
    {
      name       = "s3"
      policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
      settings   = {}
    }
  ]
}
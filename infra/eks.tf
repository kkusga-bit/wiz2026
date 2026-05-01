module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.17.2"

  cluster_name                             = "${var.project_name}-eks"
  cluster_version                          = "1.32"
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size       = 2
      max_size       = 2
      desired_size   = 2
      subnet_ids     = module.vpc.private_subnets
    }
  }
  tags = local.tags
}
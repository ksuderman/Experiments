module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.19"
  subnets         = module.vpc.private_subnets
  # subnets       = module.vpc.public_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
    ami_id           = "ami-070e4812804b3c418"  # This is a Ubuntu image for K8s 1.19 specifically
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "m5a.8xlarge"
      key_name                      = "cloudman_key_pair"
      additional_userdata           = "sudo apt-get update && sudo apt-get install -y nfs-common"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

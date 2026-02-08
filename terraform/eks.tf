module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    gpu_nodes = {
      name = "${var.cluster_name}-gpu"

      instance_types = [var.gpu_instance_type]
      capacity_type  = var.environment == "prod" ? "ON_DEMAND" : "SPOT"

      min_size     = var.gpu_min_size
      max_size     = var.gpu_max_size
      desired_size = var.gpu_desired_size

      ami_type = "AL2_x86_64_GPU"

      labels = {
        workload = "gpu"
        model    = "inference"
        environment = var.environment
      }

      taints = [
        {
          key    = "nvidia.com/gpu"
          value  = "true"
          effect = "NoSchedule"
        }
      ]

      tags = {
        NodeGroup = "GPU"
        Environment = var.environment
      }
    }

    cpu_nodes = {
      name = "${var.cluster_name}-cpu"

      instance_types = [var.cpu_instance_type]
      capacity_type  = var.environment == "prod" ? "ON_DEMAND" : "SPOT"

      min_size     = var.cpu_min_size
      max_size     = var.cpu_max_size
      desired_size = var.cpu_desired_size

      labels = {
        workload = "cpu"
        service  = "api"
        environment = var.environment
      }

      tags = {
        NodeGroup = "CPU"
        Environment = var.environment
      }
    }
  }

  manage_aws_auth_configmap = true

  tags = var.tags
}

resource "aws_eks_addon" "nvidia_device_plugin" {
  cluster_name = module.eks.cluster_name
  addon_name   = "nvidia-device-plugin"

  depends_on = [module.eks]
}

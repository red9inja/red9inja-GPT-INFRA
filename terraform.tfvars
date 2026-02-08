aws_region = "us-east-1"
cluster_name = "red9inja-gpt-cluster"
environment = "production"

vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

kubernetes_version = "1.28"

gpu_instance_type = "g4dn.xlarge"
gpu_desired_size = 1
gpu_min_size = 1
gpu_max_size = 3

cpu_instance_type = "t3.large"
cpu_desired_size = 2
cpu_min_size = 2
cpu_max_size = 5

enable_nat_gateway = true
single_nat_gateway = false

tags = {
  Owner = "red9inja"
  Project = "GPT-Infrastructure"
}

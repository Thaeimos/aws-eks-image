# Dynamic AZs and subnets
data "aws_availability_zones" "azs" {
  state = "available"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name = "eks-${random_string.suffix.result}"

  subnet_size = length(data.aws_availability_zones.azs.names)
  subnet_numbers = range(0, local.subnet_size)
  public_subnets_cidr = [ for subnet_number in local.subnet_numbers : cidrsubnet(var.main_cidr_block, 8, subnet_number) ]
  private_subnets_cidr = [ for subnet_number in local.subnet_numbers : cidrsubnet(var.main_cidr_block, 8, (subnet_number + local.subnet_size)) ]
}
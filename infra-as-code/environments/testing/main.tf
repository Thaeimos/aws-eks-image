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

  # Size of the AZs - 2 or 3 or 4
  subnet_size = length(data.aws_availability_zones.azs.names)
  # Range based on previous number - Ie. 0,1,2
  subnet_numbers = range(0, local.subnet_size)
  # We create subnets CIDR with previous info - [10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24]
  public_subnets_cidr = [ for subnet_number in local.subnet_numbers : cidrsubnet(var.main_cidr_block, 8, subnet_number) ]
  # We create subnets CIDR with previous info and offsetting it by the number of subnets created above
  # [10.0.3.0/24, 10.0.4.0/24, 10.0.5.0/24]
  private_subnets_cidr = [ for subnet_number in local.subnet_numbers : cidrsubnet(var.main_cidr_block, 8, (subnet_number + local.subnet_size)) ]
}

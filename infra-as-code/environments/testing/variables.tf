variable "region" {
  type        = string
  description = "Currently mono region. Region where to deploy."
  default     = "eu-west-2"
}

variable "name" {
  type        = string
  description = "Suffix name for all the entities to create."
  default     = "yougov-test"
}

variable "environment" {
  type        = string
  description = "The environment we are at."
  default     = "testing"
}

variable "main_cidr_block" {
  type        = string
  description = "CIDR block of IPs for the VPC."
}
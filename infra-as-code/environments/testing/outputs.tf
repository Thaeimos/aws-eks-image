output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
  sensitive   = true
}

output "region" {
  description = "AWS region."
  value       = var.region
  sensitive   = true
}

output "cluster_name" {
  description = "Kubernetes Cluster Name."
  value       = local.cluster_name
  sensitive   = true
}

output "ECR_URL" {
  description = "ECR URL where images get deployed."
  value       = aws_ecr_repository.docker_repo_frontend.repository_url
}

output "ECR_NAME" {
  description = "ECR name. Needed to login into the proper ECR registry on later stages."
  value       = aws_ecr_repository.docker_repo_frontend.name
}
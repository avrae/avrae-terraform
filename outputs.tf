output "taine_ecr_repository" {
  value = module.ecr_taine.ecr_repo_url
}

output "avrae_bot_ecr_repository" {
  value = module.ecr_avrae_bot.ecr_repo_url
}

output "avrae_service_ecr_repository" {
  value = module.ecr_avrae_service.ecr_repo_url
}

output "deploy_iam_access_key" {
  value = module.iam_deploy.iam_access_key
}

output "avrae_redis_hostname" {
  value = module.redis_avrae.hostname
}

output "ec2_mdb_access_ip" {
  value = aws_instance.dev_mdb_access.public_dns
}


output "es_endpoint" {
  value = "https://${aws_elasticsearch_domain.workshop_es.endpoint}"
}
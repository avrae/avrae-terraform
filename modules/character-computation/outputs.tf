output "api_endpoint" {
  value = "https://${aws_api_gateway_rest_api.character_computation_api.id}.execute-api.us-east-1.amazonaws.com/prod"
}

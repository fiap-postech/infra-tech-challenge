output "database" {
  sensitive = true
  value = {
    endpoint = aws_db_instance.tech_challenge_db.endpoint
    username = aws_db_instance.tech_challenge_db.username
    password = aws_db_instance.tech_challenge_db.password
  }
}

output "apigw_endpoint" {
  value = aws_apigatewayv2_api.apigw_http_endpoint.api_endpoint
}
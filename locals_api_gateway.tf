locals {
  api_gateway = {
    name     = "tech-challenge-api"
    protocol = "HTTP"

    log_group = {
      name              = "/aws/api-gateway/tech-challenge-api"
      retention_in_days = 1
    }

    vpc_link = {
      name = "vpclink_apigw_to_alb"
    }

    authorization_lambda_name = "json-web-token-verifier"

    integration = {

      integration_type       = "HTTP_PROXY"
      integration_method     = "ANY"
      connection_type        = "VPC_LINK"
      payload_format_version = "1.0"
    }

    authorization = {
      authorizer_type                   = "REQUEST"
      identity_sources                  = ["$request.header.Authorization"]
      name                              = "ESFINGE"
      authorizer_payload_format_version = "1.0"
      authorizer_result_ttl_in_seconds  = 300
      enable_simple_responses           = false
    }
  }
}
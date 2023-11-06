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

    integration = {

      integration_type       = "HTTP_PROXY"
      integration_method     = "ANY"
      connection_type        = "VPC_LINK"
      payload_format_version = "1.0"
    }
  }
}
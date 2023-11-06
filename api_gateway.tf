resource "aws_apigatewayv2_vpc_link" "vpclink_apigw_to_alb" {
  name               = local.api_gateway.vpc_link.name
  security_group_ids = []
  subnet_ids         = [for s in data.aws_subnet.private_selected : s.id]

  depends_on = [data.aws_subnet.private_selected]
}

resource "aws_apigatewayv2_api" "apigw_http_endpoint" {
  name          = local.api_gateway.name
  protocol_type = local.api_gateway.protocol
}

resource "aws_apigatewayv2_authorizer" "authorizer" {
  api_id                            = aws_apigatewayv2_api.apigw_http_endpoint.id
  authorizer_type                   = local.api_gateway.authorization.authorizer_type
  identity_sources                  = local.api_gateway.authorization.identity_sources
  name                              = local.api_gateway.authorization.name
  authorizer_payload_format_version = local.api_gateway.authorization.authorizer_payload_format_version
  authorizer_result_ttl_in_seconds  = local.api_gateway.authorization.authorizer_result_ttl_in_seconds
  enable_simple_responses           = local.api_gateway.authorization.enable_simple_responses
  authorizer_uri                    = data.aws_lambda_function.lambda_authorizer.invoke_arn
}

resource "aws_apigatewayv2_integration" "apigw_integration" {
  api_id                 = aws_apigatewayv2_api.apigw_http_endpoint.id
  integration_type       = local.api_gateway.integration.integration_type
  integration_uri        = aws_lb_listener.listener_http.arn
  integration_method     = local.api_gateway.integration.integration_method
  connection_type        = local.api_gateway.integration.connection_type
  connection_id          = aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb.id
  payload_format_version = local.api_gateway.integration.payload_format_version

  depends_on = [
    aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb,
    aws_apigatewayv2_api.apigw_http_endpoint,
    aws_lb_listener.listener_http
  ]
}

resource "aws_apigatewayv2_route" "apigw_route" {
  api_id             = aws_apigatewayv2_api.apigw_http_endpoint.id
  route_key          = "ANY /{proxy+}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
  target             = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"
  depends_on = [
    aws_apigatewayv2_integration.apigw_integration,
    aws_apigatewayv2_authorizer.authorizer
  ]
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.apigw_http_endpoint.name}"

  retention_in_days = 1
}

resource "aws_apigatewayv2_stage" "apigw_stage" {
  api_id      = aws_apigatewayv2_api.apigw_http_endpoint.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
  depends_on = [
    aws_cloudwatch_log_group.api_gw,
    aws_apigatewayv2_api.apigw_http_endpoint
  ]
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda_authorizer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.apigw_http_endpoint.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "auth_integration" {
  api_id = aws_apigatewayv2_api.apigw_http_endpoint.id

  integration_uri  = data.aws_lambda_function.lambda_signer.invoke_arn
  integration_type = "AWS_PROXY"

  depends_on = [data.aws_lambda_function.lambda_signer]
}

resource "aws_apigatewayv2_route" "auth_route" {
  api_id    = aws_apigatewayv2_api.apigw_http_endpoint.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.auth_integration.id}"

  depends_on = [
    aws_apigatewayv2_integration.apigw_integration,
    aws_apigatewayv2_authorizer.authorizer
  ]
}

resource "aws_lambda_permission" "api_gw_to_lambda_signer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda_signer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.apigw_http_endpoint.execution_arn}/*/*"

  depends_on = [
    data.aws_lambda_function.lambda_signer,
    aws_apigatewayv2_api.apigw_http_endpoint
  ]
}
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
  api_id     = aws_apigatewayv2_api.apigw_http_endpoint.id
  route_key  = "ANY /{proxy+}"
  target     = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"
  depends_on = [aws_apigatewayv2_integration.apigw_integration]
}

resource "aws_apigatewayv2_stage" "apigw_stage" {
  api_id      = aws_apigatewayv2_api.apigw_http_endpoint.id
  name        = "$default"
  auto_deploy = true
  depends_on  = [aws_apigatewayv2_api.apigw_http_endpoint]
}
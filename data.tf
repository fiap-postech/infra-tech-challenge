data "aws_vpc" "main" {
  tags = {
    Name = local.vpc_name
  }
}

data "aws_subnets" "private_subnet_ids" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Scope"
    values = ["private"]
  }

  depends_on = [data.aws_vpc.main]
}


data "aws_subnet" "private_selected" {
  for_each = toset(data.aws_subnets.private_subnet_ids.ids)
  id       = each.value

  depends_on = [data.aws_subnets.private_subnet_ids]
}

data "aws_subnets" "database_subnet_ids" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Scope"
    values = ["database"]
  }

  depends_on = [data.aws_vpc.main]
}


data "aws_subnet" "database_selected" {
  for_each = toset(data.aws_subnets.database_subnet_ids.ids)
  id       = each.value

  depends_on = [data.aws_subnets.database_subnet_ids]
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = local.ecs.cluster_name
}

data "aws_security_group" "vpc_endpoint_sm_cl" {
  name = "vpc-endpoints-secretsmanager-cloudwatchlogs-sg"
}

data "aws_lambda_function" "lambda_authorizer" {
  function_name = local.api_gateway.authorization_lambda_name
}
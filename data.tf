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
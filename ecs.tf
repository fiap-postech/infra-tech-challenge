resource "aws_security_group" "alb_sg" {
  name        = local.ecs.alb.sg.name
  description = local.ecs.alb.sg.description
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = local.ecs.alb.sg.ingress.http.description
      from_port        = local.ecs.alb.sg.ingress.http.from_port
      to_port          = local.ecs.alb.sg.ingress.http.to_port
      protocol         = local.ecs.alb.sg.ingress.http.protocol
      cidr_blocks      = local.ecs.alb.sg.ingress.http.cidr_blocks
      ipv6_cidr_blocks = local.ecs.alb.sg.ingress.http.ipv6_cidr_blocks
      prefix_list_ids  = local.ecs.alb.sg.ingress.http.prefix_list_ids
      security_groups  = local.ecs.alb.sg.ingress.http.security_groups
      self             = local.ecs.alb.sg.ingress.http.self
    }
  ]

  egress {
    from_port        = local.ecs.alb.sg.egress.from_port
    to_port          = local.ecs.alb.sg.egress.to_port
    protocol         = local.ecs.alb.sg.egress.protocol
    cidr_blocks      = local.ecs.alb.sg.egress.cidr_blocks
    ipv6_cidr_blocks = local.ecs.alb.sg.egress.ipv6_cidr_blocks
  }

  tags = {
    Name = local.ecs.alb.sg.name
  }
}

resource "aws_security_group" "service_sg" {
  name        = local.ecs.sg.name
  description = local.ecs.sg.description
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = local.ecs.sg.ingress.description
      from_port        = local.ecs.sg.ingress.from_port
      to_port          = local.ecs.sg.ingress.to_port
      protocol         = local.ecs.sg.ingress.protocol
      cidr_blocks      = local.ecs.sg.ingress.cidr_blocks
      ipv6_cidr_blocks = local.ecs.sg.ingress.ipv6_cidr_blocks
      prefix_list_ids  = local.ecs.sg.ingress.prefix_list_ids
      security_groups  = [aws_security_group.alb_sg.id]
      self             = local.ecs.sg.ingress.self
    }
  ]

  egress {
    from_port        = local.ecs.sg.egress.from_port
    to_port          = local.ecs.sg.egress.to_port
    protocol         = local.ecs.sg.egress.protocol
    cidr_blocks      = local.ecs.sg.egress.cidr_blocks
    ipv6_cidr_blocks = local.ecs.sg.egress.ipv6_cidr_blocks
  }

  tags = {
    Name = local.ecs.sg.name
  }
}
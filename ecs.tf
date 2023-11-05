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

  depends_on = [aws_security_group.alb_sg]
}

resource "aws_lb" "alb" {
  name               = local.ecs.alb.name
  internal           = local.ecs.alb.internal
  load_balancer_type = local.ecs.alb.load_balancer_type
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for s in data.aws_subnet.private_selected : s.id]

  enable_deletion_protection = local.ecs.alb.enable_deletion_protection

  tags = {
    name = local.ecs.alb.name
  }

  depends_on = [aws_security_group.alb_sg, data.aws_subnet.private_selected]
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = local.ecs.alb.listener.http.port
  protocol          = local.ecs.alb.listener.http.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  depends_on = [
    aws_lb.alb,
    aws_lb_target_group.target_group
  ]
}

resource "aws_lb_target_group" "target_group" {
  name        = local.ecs.alb.target_group.name
  port        = local.ecs.alb.target_group.port
  protocol    = local.ecs.alb.target_group.protocol
  vpc_id      = data.aws_vpc.main.id
  target_type = local.ecs.alb.target_group.target_type

  health_check {
    enabled             = local.ecs.alb.target_group.health_check.enabled
    healthy_threshold   = local.ecs.alb.target_group.health_check.healthy_threshold
    interval            = local.ecs.alb.target_group.health_check.interval
    matcher             = local.ecs.alb.target_group.health_check.matcher
    path                = local.ecs.alb.target_group.health_check.path
    port                = local.ecs.alb.target_group.health_check.port
    protocol            = local.ecs.alb.target_group.health_check.protocol
    timeout             = local.ecs.alb.target_group.health_check.timeout
    unhealthy_threshold = local.ecs.alb.target_group.health_check.unhealthy_threshold
  }
}
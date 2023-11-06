# resource "aws_security_group" "alb_sg" {
#   name        = local.ecs.alb.sg.name
#   description = local.ecs.alb.sg.description
#   vpc_id      = data.aws_vpc.main.id

#   ingress = [
#     {
#       description      = local.ecs.alb.sg.ingress.http.description
#       from_port        = local.ecs.alb.sg.ingress.http.from_port
#       to_port          = local.ecs.alb.sg.ingress.http.to_port
#       protocol         = local.ecs.alb.sg.ingress.http.protocol
#       cidr_blocks      = local.ecs.alb.sg.ingress.http.cidr_blocks
#       ipv6_cidr_blocks = local.ecs.alb.sg.ingress.http.ipv6_cidr_blocks
#       prefix_list_ids  = local.ecs.alb.sg.ingress.http.prefix_list_ids
#       security_groups  = local.ecs.alb.sg.ingress.http.security_groups
#       self             = local.ecs.alb.sg.ingress.http.self
#     }
#   ]

#   egress {
#     from_port        = local.ecs.alb.sg.egress.from_port
#     to_port          = local.ecs.alb.sg.egress.to_port
#     protocol         = local.ecs.alb.sg.egress.protocol
#     cidr_blocks      = local.ecs.alb.sg.egress.cidr_blocks
#     ipv6_cidr_blocks = local.ecs.alb.sg.egress.ipv6_cidr_blocks
#   }

#   tags = {
#     Name = local.ecs.alb.sg.name
#   }
# }

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

# resource "aws_lb" "alb" {
#   name               = local.ecs.alb.name
#   internal           = local.ecs.alb.internal
#   load_balancer_type = local.ecs.alb.load_balancer_type
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = [for s in data.aws_subnet.private_selected : s.id]

#   enable_deletion_protection = local.ecs.alb.enable_deletion_protection

#   tags = {
#     name = local.ecs.alb.name
#   }

#   depends_on = [aws_security_group.alb_sg, data.aws_subnet.private_selected]
# }

# resource "aws_lb_listener" "listener_http" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = local.ecs.alb.listener.http.port
#   protocol          = local.ecs.alb.listener.http.protocol

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group.arn
#   }

#   depends_on = [
#     aws_lb.alb,
#     aws_lb_target_group.target_group
#   ]
# }

# resource "aws_lb_target_group" "target_group" {
#   name        = local.ecs.alb.target_group.name
#   port        = local.ecs.alb.target_group.port
#   protocol    = local.ecs.alb.target_group.protocol
#   vpc_id      = data.aws_vpc.main.id
#   target_type = local.ecs.alb.target_group.target_type

#   health_check {
#     enabled             = local.ecs.alb.target_group.health_check.enabled
#     healthy_threshold   = local.ecs.alb.target_group.health_check.healthy_threshold
#     interval            = local.ecs.alb.target_group.health_check.interval
#     matcher             = local.ecs.alb.target_group.health_check.matcher
#     path                = local.ecs.alb.target_group.health_check.path
#     port                = local.ecs.alb.target_group.health_check.port
#     protocol            = local.ecs.alb.target_group.health_check.protocol
#     timeout             = local.ecs.alb.target_group.health_check.timeout
#     unhealthy_threshold = local.ecs.alb.target_group.health_check.unhealthy_threshold
#   }
# }

# resource "aws_cloudwatch_log_group" "service_log_group" {
#   name              = local.ecs.log_group.name
#   retention_in_days = local.ecs.log_group.retention_in_days

#   tags = {
#     name = local.ecs.log_group.name
#   }
# }

# resource "aws_iam_role" "service_execution_role" {
#   name = local.ecs.iam.role_name
#   assume_role_policy = jsonencode({
#     Version : "2012-10-17"
#     Statement : [
#       {
#         Sid    = "01"
#         Effect = "Allow"
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Cluster Execution Role
# resource "aws_iam_role_policy" "service_execution_policy" {
#   name = local.ecs.iam.policy_name
#   role = aws_iam_role.service_execution_role.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "01"
#         Effect = "Allow"
#         Action = [
#           "logs:PutLogEvents",
#           "logs:CreateLogStream"
#         ]
#         Resource = "*"
#       },
#       {
#         Sid    = "02"
#         Effect = "Allow"
#         Action = "secretsmanager:GetSecretValue"
#         Resource = [
#           aws_secretsmanager_secret.app_database_password_secret.arn
#         ]
#       }
#     ]
#   })

#   depends_on = [
#     aws_iam_role.service_execution_role,
#     aws_secretsmanager_secret.app_database_password_secret
#   ]
# }

# resource "aws_ecs_task_definition" "task_definition" {
#   family                   = local.ecs.task_definition.family
#   execution_role_arn       = aws_iam_role.service_execution_role.arn
#   task_role_arn            = aws_iam_role.service_execution_role.arn
#   requires_compatibilities = local.ecs.task_definition.requires_compatibilities
#   network_mode             = local.ecs.task_definition.network_mode
#   cpu                      = local.ecs.task_definition.cpu
#   memory                   = local.ecs.task_definition.memory

#   container_definitions = jsonencode([
#     {
#       name              = local.ecs.task_definition.container_definitions.name
#       image             = local.ecs.task_definition.container_definitions.image
#       cpu               = local.ecs.task_definition.container_definitions.cpu
#       memory            = local.ecs.task_definition.container_definitions.memory
#       memoryReservation = local.ecs.task_definition.container_definitions.memoryReservation
#       essential         = local.ecs.task_definition.container_definitions.essential
#       logConfiguration = {
#         "logDriver"     = "awslogs"
#         "secretOptions" = null
#         "options" = {
#           "awslogs-group"         = aws_cloudwatch_log_group.service_log_group.name
#           "awslogs-region"        = "us-east-1"
#           "awslogs-stream-prefix" = "ecs"
#         }
#       }
#       portMappings = local.ecs.task_definition.container_definitions.portMappings
#       entryPoint   = local.ecs.task_definition.container_definitions.entryPoint
#       environment = concat(
#         local.ecs.task_definition.container_definitions.environment,
#         [
#           {
#             name  = "spring.data.redis.host"
#             value = aws_elasticache_replication_group.redis.primary_endpoint_address
#           },
#           {
#             name  = "db.host"
#             value = aws_db_instance.tech_challenge_db.address
#           }
#         ]
#       )
#       secrets = [
#         {
#           name      = "db.password"
#           valueFrom = aws_secretsmanager_secret.app_database_password_secret.arn
#         }
#       ]
#     }
#   ])


#   depends_on = [
#     aws_iam_role.service_execution_role,
#     aws_iam_role_policy.service_execution_policy,
#     aws_cloudwatch_log_group.service_log_group
#   ]
# }

# resource "aws_ecs_service" "service" {
#   name                              = local.ecs.service.name
#   task_definition                   = "${aws_ecs_task_definition.task_definition.family}:${max("${aws_ecs_task_definition.task_definition.revision}")}"
#   desired_count                     = local.ecs.service.desired_count
#   launch_type                       = local.ecs.service.launch_type
#   cluster                           = data.aws_ecs_cluster.cluster.id
#   health_check_grace_period_seconds = local.ecs.service.health_check_grace_period_seconds

#   network_configuration {
#     security_groups = [aws_security_group.service_sg.id]
#     subnets         = [for s in data.aws_subnet.private_selected : s.id]
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.target_group.arn
#     container_name   = local.ecs.task_definition.container_definitions.name
#     container_port   = local.ecs.service.load_balancer.container_port
#   }

#   depends_on = [
#     data.aws_ecs_cluster.cluster,
#     aws_lb.alb,
#     aws_lb_target_group.target_group,
#     aws_ecs_task_definition.task_definition,
#     aws_db_instance.tech_challenge_db,
#     aws_elasticache_replication_group.redis
#   ]
# }

# resource "aws_security_group_rule" "ecs_to_vpc_endpoints" {
#   type                     = "ingress"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.service_sg.id

#   security_group_id = data.aws_security_group.vpc_endpoint_sm_cl.id
#   depends_on        = [data.aws_security_group.vpc_endpoint_sm_cl, aws_security_group.service_sg]

# }

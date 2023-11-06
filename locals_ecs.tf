locals {
  ecs = {
    cluster_name = "tech-challenge"

    sg = {
      name        = "tech-challenge-sg"
      description = "tech-challenge security group"

      ingress = {
        description      = "Allow Request From Target Group"
        from_port        = 8080
        to_port          = 8080
        protocol         = "tcp"
        cidr_blocks      = []
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        self             = null
      }


      egress = {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
      }
    }

    log_group = {
      name              = "/ecs/tech-challenge"
      retention_in_days = 1
    }

    iam = {
      role_name   = "tech_challenge_service_execution_role"
      policy_name = "tech_challenge_service_execution_policy"
    }

    task_definition = {
      family                   = "tsk-tech-challenge"
      requires_compatibilities = ["FARGATE"]
      network_mode             = "awsvpc"
      cpu                      = 1024
      memory                   = 2048

      container_definitions = {
        name              = "tech-challenge-container"
        image             = "fiapsoat2grupo13/tech-challenge-service:latest"
        cpu               = 1
        memory            = 2048
        memoryReservation = 2048
        essential         = true
        portMappings = [
          {
            containerPort = 8080
            protocol      = "tcp"
            hostPort      = 8080
          }
        ]
        entryPoint = [
          "java",
          "-Duser.timezone=GMT-3",
          "-Djava.security.egd=file:/dev/./urandom",
          "-jar",
          "tech-challenge.jar"
        ]
        environment = [
          {
            name  = "spring.profiles.active"
            value = "prod"
          }
        ]
      }
    }

    alb = {
      name                       = "tech-challenge-alb"
      internal                   = true
      load_balancer_type         = "application"
      enable_deletion_protection = false

      listener = {
        http = {
          port     = "80"
          protocol = "HTTP"
        }
      }

      target_group = {
        name        = "tech-challenge-tg"
        port        = 8080
        protocol    = "HTTP"
        target_type = "ip"

        health_check = {
          enabled             = true
          healthy_threshold   = 3
          interval            = 30
          matcher             = "200"
          path                = "/monitor/health"
          port                = 8080
          protocol            = "HTTP"
          timeout             = 10
          unhealthy_threshold = 10
        }
      }

      sg = {
        name        = "alb-tech-challenge-sg"
        description = "tech-challenge alb security group"

        ingress = {
          http = {
            description      = "Allow HTTP"
            from_port        = 80
            to_port          = 80
            protocol         = "tcp"
            cidr_blocks      = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            prefix_list_ids  = []
            security_groups  = []
            self             = null
          }
        }

        egress = {
          from_port        = 0
          to_port          = 0
          protocol         = "-1"
          cidr_blocks      = ["0.0.0.0/0"]
          ipv6_cidr_blocks = ["::/0"]
        }
      }
    }

    service = {
      name                              = "tech-challenge-service"
      desired_count                     = 1
      launch_type                       = "FARGATE"
      health_check_grace_period_seconds = 120
      load_balancer = {
        container_port = "8080"
      }
    }
  }
}
locals {
  default_region = "us-east-1"

  vpc_name = "tc-vpc"

  bucket = {
    name      = "tech-challenge-cdn"
    log       = "log-tech-challenge-cdn"
    origin_id = "tech-challenge-cdn-origin"
  }

  rds = {
    sg = {
      name = "rds_sg"
      ingress = {
        from_port = 3306
        to_port   = 3306
        protocol  = "tcp"
      }
      egress = {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    subnet_group = {
      name = "tech-challenge-rds-subnet-group"
    }

    instance = {
      engine                     = "mysql"
      identifier                 = "tech-challenge-database"
      allocated_storage          = 10
      engine_version             = "8.0.34"
      instance_class             = "db.t2.micro"
      username                   = "admin"
      password_admin_secret_name = "database/Admin/Password"
      password_app_secret_name   = "database/Service/Password"
      parameter_group_name       = "default.mysql8.0"
      skip_final_snapshot        = true
      publicly_accessible        = false
    }
  }

  redis = {
    sg = {
      name = "cache_sg"

      ingress = {
        from_port = 6379
        to_port   = 6379
        protocol  = "tcp"
      }

      egress = {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    subnet_group = {
      name = "tech-challenge-redis-subnet-group"
    }

    replication_group = {
      availability_zones         = ["us-east-1a"]
      replication_group_id       = "tech-challenge-redis"
      description                = "cache for customer cart purposes"
      node_type                  = "cache.t3.micro"
      engine                     = "redis"
      engine_version             = "6.x"
      num_cache_clusters         = 1
      parameter_group_name       = "default.redis6.x"
      port                       = 6379
      transit_encryption_enabled = false
    }
  }

  ecs = {
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
  }
}
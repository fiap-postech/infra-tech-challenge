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
}
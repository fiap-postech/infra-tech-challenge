locals {
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

    secrets = {
      name = "service/Database/Credential"
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
      publicly_accessible        = true
    }

    setup = {
      schema = {
        name          = "tech_challenge"
        character_set = "utf8mb4"
        collation     = "utf8mb4_0900_ai_ci"
      }
      user = {
        name = "sys_tech_challenge"
        host = "%"
      }

      grant_privileges = ["ALL PRIVILEGES"]

    }
  }
}
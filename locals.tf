locals {
  default_region = "us-east-1"

  bucket = {
    name      = "tech-challenge-cdn"
    log       = "log-tech-challenge-cdn"
    origin_id = "tech-challenge-cdn-origin"
  }

  rds = {
    sg = {
      name = "rds_sg"
      ingress = {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      egress = {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    instance = {
      engine               = "mysql"
      identifier           = "tech-challenge-database"
      allocated_storage    = 10
      engine_version       = "8.0.34"
      instance_class       = "db.t2.micro"
      username             = "admin"
      password_admin_secret_name = "database/Admin/Password"
      password_app_secret_name = "database/Service/Password"
      parameter_group_name = "default.mysql8.0"
      skip_final_snapshot  = true
      publicly_accessible  = false
    }
  }
}
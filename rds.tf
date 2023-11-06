resource "aws_security_group" "rds_sg" {
  name   = local.rds.sg.name
  vpc_id = data.aws_vpc.main.id

  ingress = [
    {
      description      = "allow connection from private subnet"
      from_port        = local.rds.sg.ingress.from_port
      to_port          = local.rds.sg.ingress.to_port
      protocol         = local.rds.sg.ingress.protocol
      cidr_blocks      = [for s in data.aws_subnet.private_selected : s.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = null

    },
    {
      description      = "allow connection from world"
      from_port        = local.rds.sg.ingress.from_port
      to_port          = local.rds.sg.ingress.to_port
      protocol         = local.rds.sg.ingress.protocol
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = null
    }
  ]
  egress {
    from_port   = local.rds.sg.egress.from_port
    to_port     = local.rds.sg.egress.to_port
    protocol    = local.rds.sg.egress.protocol
    cidr_blocks = local.rds.sg.egress.cidr_blocks
  }

  depends_on = [data.aws_subnet.private_selected]
}

data "aws_secretsmanager_secret" "database_admin_secret" {
  name = local.rds.instance.password_admin_secret_name
}

data "aws_secretsmanager_secret_version" "database_admin_secret_version" {
  secret_id = data.aws_secretsmanager_secret.database_admin_secret.id

  depends_on = [data.aws_secretsmanager_secret.database_admin_secret]
}

resource "aws_secretsmanager_secret" "app_database_password_secret" {
  name = local.rds.instance.password_app_secret_name
}

resource "aws_secretsmanager_secret_version" "app_database_password_version" {
  secret_id     = aws_secretsmanager_secret.app_database_password_secret.id
  secret_string = var.app_database_password

  depends_on = [aws_secretsmanager_secret.app_database_password_secret]
}

resource "aws_db_subnet_group" "tech_challenge_rds_subnet_group" {
  name       = local.rds.subnet_group.name
  subnet_ids = [for s in data.aws_subnet.private_selected : s.id]

  tags = {
    Name = local.rds.subnet_group.name
  }

  depends_on = [data.aws_subnet.private_selected]
}

resource "aws_db_instance" "tech_challenge_db" {
  engine                 = local.rds.instance.engine
  identifier             = local.rds.instance.identifier
  allocated_storage      = local.rds.instance.allocated_storage
  engine_version         = local.rds.instance.engine_version
  instance_class         = local.rds.instance.instance_class
  username               = local.rds.instance.username
  password               = data.aws_secretsmanager_secret_version.database_admin_secret_version.secret_string
  parameter_group_name   = local.rds.instance.parameter_group_name
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  skip_final_snapshot    = local.rds.instance.skip_final_snapshot
  publicly_accessible    = local.rds.instance.publicly_accessible
  db_subnet_group_name   = aws_db_subnet_group.tech_challenge_rds_subnet_group.id

  depends_on = [
    data.aws_secretsmanager_secret_version.database_admin_secret_version,
    aws_db_subnet_group.tech_challenge_rds_subnet_group,
    aws_security_group.rds_sg
  ]
}

# resource "mysql_database" "service_database" {
#   name                  = "tech_challenge"
#   default_character_set = "utf8mb4"
#   default_collation     = "utf8mb4_0900_ai_ci"

#   depends_on = [aws_db_instance.tech_challenge_db]
# }
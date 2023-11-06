resource "aws_security_group" "rds_sg" {
  name   = local.rds.sg.name
  vpc_id = data.aws_vpc.main.id

  ingress = [
    {
      description      = "allow connection from database subnet"
      from_port        = local.rds.sg.ingress.from_port
      to_port          = local.rds.sg.ingress.to_port
      protocol         = local.rds.sg.ingress.protocol
      cidr_blocks      = [for s in data.aws_subnet.database_selected : s.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = null
    },
    {
      description      = "allow connection from ecs"
      from_port        = local.rds.sg.ingress.from_port
      to_port          = local.rds.sg.ingress.to_port
      protocol         = local.rds.sg.ingress.protocol
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = [aws_security_group.service_sg.id]
      self             = null
    },
    {
      description      = "allow connection from all world"
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

  depends_on = [
    data.aws_subnet.database_selected,
    aws_security_group.service_sg
  ]
}

data "aws_secretsmanager_secret" "database_admin_secret" {
  name = local.rds.instance.password_admin_secret_name
}

data "aws_secretsmanager_secret_version" "database_admin_secret_version" {
  secret_id = data.aws_secretsmanager_secret.database_admin_secret.id

  depends_on = [data.aws_secretsmanager_secret.database_admin_secret]
}

resource "aws_secretsmanager_secret" "app_database_password_secret" {
  name                    = local.rds.instance.password_app_secret_name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app_database_password_version" {
  secret_id     = aws_secretsmanager_secret.app_database_password_secret.id
  secret_string = var.app_database_password

  depends_on = [aws_secretsmanager_secret.app_database_password_secret]
}

resource "aws_db_subnet_group" "tech_challenge_rds_subnet_group" {
  name       = local.rds.subnet_group.name
  subnet_ids = [for s in data.aws_subnet.database_selected : s.id]

  tags = {
    Name = local.rds.subnet_group.name
  }

  depends_on = [data.aws_subnet.database_selected]
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

resource "mysql_database" "service_database" {
  name                  = local.rds.setup.schema.name
  default_character_set = local.rds.setup.schema.character_set
  default_collation     = local.rds.setup.schema.collation

  depends_on = [aws_db_instance.tech_challenge_db]
}

resource "mysql_user" "service_user" {
  user               = local.rds.setup.user.name
  host               = local.rds.setup.user.host
  plaintext_password = aws_secretsmanager_secret_version.app_database_password_version.secret_string

  depends_on = [mysql_database.service_database]
}

resource "mysql_grant" "service_user_grant" {
  user       = mysql_user.service_user.user
  host       = mysql_user.service_user.host
  database   = mysql_database.service_database.name
  privileges = local.rds.setup.grant_privileges

  depends_on = [mysql_user.service_user]
}

resource "aws_secretsmanager_secret" "database_credential" {
  name                    = local.rds.secrets.name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "signer_version" {
  secret_id     = aws_secretsmanager_secret.database_credential.id
  secret_string = <<EOF
   {
    "host": "${aws_db_instance.tech_challenge_db.address}",
    "port": ${aws_db_instance.tech_challenge_db.port},
    "username": "${local.rds.setup.user.name}",
    "password": "${aws_secretsmanager_secret_version.app_database_password_version.secret_string}",
    "schema": "${mysql_database.service_database.name}"
   }
EOF

  depends_on = [
    aws_db_instance.tech_challenge_db,
    mysql_database.service_database,
    aws_secretsmanager_secret_version.app_database_password_version
  ]
}
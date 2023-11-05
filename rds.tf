resource "aws_security_group" "rds_sg" {
  name   = local.rds.sg.name
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port        = local.rds.sg.ingress.from_port
    to_port          = local.rds.sg.ingress.to_port
    protocol         = local.rds.sg.ingress.protocol
    cidr_blocks      = [for s in data.aws_subnet.private_selected : s.cidr_block]
    ipv6_cidr_blocks = []
  }
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

  depends_on = [
    data.aws_secretsmanager_secret_version.database_admin_secret_version,
    aws_security_group.rds_sg
  ]
}

# resource "null_resource" "db_setup" {
#   triggers = {
#     file = filesha1("rds/setup.sql")
#   }

#   provisioner "local-exec" {
#     command = <<-EOF
# 			while read line; do
# 				echo "$line"
# 				aws rds-data execute-statement --resource-arn "$DB_ARN" --database  "$DB_NAME" --secret-arn "$SECRET_ARN" --sql "$line"
# 			done  < <(awk 'BEGIN{RS=";\n"}{gsub(/\n/,""); if(NF>0) {print $0";"}}' initial.sql)
# 			EOF
#     environment = {
#       DB_ENDPOINT = aws_db_instance.tech_challenge_db.endpoint
#       ADMIN_PASSWORD = data.aws_secretsmanager_secret_version.database_admin_secret_version.secret_string
#     }
#     interpreter = ["bash", "-c"]
#   }
# }
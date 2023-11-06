provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["598135944514"]

  default_tags {
    tags = {
      "worload" = "tech-challenge"
    }
  }
}

provider "mysql" {
    username = "admin"
    password = "${data.aws_secretsmanager_secret.database_admin_secret.secret_string}"
    endpoint = "${aws_db_instance.tech_challenge_db.endpoint}"
}
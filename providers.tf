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
  username = aws_db_instance.tech_challenge_db.username
  password = aws_db_instance.tech_challenge_db.password
  endpoint = aws_db_instance.tech_challenge_db.endpoint
}

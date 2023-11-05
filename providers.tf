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

}
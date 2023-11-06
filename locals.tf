locals {
  default_region = "us-east-1"

  vpc_name = "tc-vpc"

  bucket = {
    name      = "tech-challenge-cdn"
    log       = "log-tech-challenge-cdn"
    origin_id = "tech-challenge-cdn-origin"
  }
}
output "output" {
  sensitive = true
  value = {
    endpoint = aws_db_instance.tech_challenge_db.endpoint
    username = aws_db_instance.tech_challenge_db.username
    password = aws_db_instance.tech_challenge_db.password
  }
}
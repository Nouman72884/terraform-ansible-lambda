terraform {
  backend "s3" {
    bucket         = "s3lockstate"
    key            = "state"
    encrypt        = true
    region         = "us-east-1"
    dynamodb_table = "lockstate"
  }
}
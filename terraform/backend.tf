terraform {
  backend "s3" {
    bucket         = "test-app-s3-bucket1"
    key            = "terraform_statefile"   
    region         = "us-east-1"
    dynamodb_table = "test-app" 
  }
}

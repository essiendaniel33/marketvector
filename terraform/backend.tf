terraform {
  backend "s3" {
    bucket         = "var.s3_bucket_name"
    key            = "terraform_statefile"   
    region         = "us-east-1"
    dynamodb_table = "var.dynamodb_table_name" 
  }
}

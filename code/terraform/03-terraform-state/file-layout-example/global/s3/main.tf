terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.5"     
    }

  }
  required_version = ">= 0.12, <= 1.0.2"
  # after the bucket name and dynamodb table created, include this block
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "mysf-uat-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "ap-southeast-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "global-terraform.tfstate"
    encrypt        = true
  }
  
}
 
provider "aws" {
  region = "ap-southeast-2"

  # Allow any 2.x version of the AWS provider
  #version = "~> 2.0"
}

resource "aws_s3_bucket" "terraform_state" {

  bucket = var.bucket_name

  // This is only here so we can destroy the bucket as part of automated tests. You should not copy this for production
  // usage
  force_destroy = true

  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

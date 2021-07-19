terraform {
  required_providers {
    aws = {
      source  = "Hashicorp/aws"
      version = "~> 3.5"
    }
  }
  required_version = ">= 0.12, <= 1.0.2"
  backend "s3" {
    key            = "stage/s3/terraform.tfstate"
  }
}



provider "aws" {
  region = var.region
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"

  username            = "admin"

  name                = var.db_name
  skip_final_snapshot = true

  password            = var.db_password
}


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
    key            = "workspace-example/terraform.tfstate"
  } 
}

provider "aws" {
  region = "ap-southeast-2"

}

resource "aws_instance" "example" {
# using ubuntu ami
  ami           = "ami-0f39d06d145e9bb63"
  instance_type = terraform.workspace == "default" ? "t2.micro" : "t2.medium"

}


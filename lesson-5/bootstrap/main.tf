# Bootstrap конфігурація для створення S3 та DynamoDB
# Запустіть цей файл першим: terraform -chdir=bootstrap init && terraform -chdir=bootstrap apply

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "lesson-5"
      Environment = "development"
      ManagedBy   = "terraform-bootstrap"
    }
  }
}

# Створюємо тільки S3 та DynamoDB для backend
module "s3_backend" {
  source      = "../modules/s3-backend"
  bucket_name = "artur-mykhailiuk-terraform-state"
  table_name  = "terraform-locks"
}

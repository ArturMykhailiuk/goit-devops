output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.s3_backend.bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = module.s3_backend.dynamodb_table_name
}

output "next_steps" {
  description = "Instructions for next steps"
  value = <<EOF
Bootstrap completed successfully!

Next steps:
1. cd .. (go back to main directory)
2. terraform init
3. terraform apply

The S3 backend is now ready to use.
EOF
}

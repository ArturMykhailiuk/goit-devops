variable "ecr_name" {
  description = "Name of the ECR repository"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9._-]*[a-z0-9])?$", var.ecr_name))
    error_message = "ECR repository name must contain only lowercase letters, numbers, hyphens, underscores, and periods."
  }
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}


variable "s3_bucket_name" {
  description = "This variable holds s3 bucket name"
  default = "my-app-bucket-jk"
  type = string
}

variable "env" {
  description = "This variable holds the environment"
  default     = "dev"
  type        = string
}

variable "s3_bucket_count" {
  description = "This variable holds s3 bucket count"
  type = number
}

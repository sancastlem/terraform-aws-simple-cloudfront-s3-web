variable "name" {
  description = "Name of the application"
}

variable "route53_zone_id" {
  description = "Route 53 zone id"
}

variable "environment" {
  description = "Environment [dev, pre, prod]"
}

variable "ssl_arn" {
  description = "Arn of the ssl certificate"
}

variable "url" {
  description = "Url of the app"
}

variable "cloudfront_origin_path" {
  description = "Root path in the bucket for the cloudfront"
  default     = ""
}

variable "acl_name" {
  description = "Canned ACL"
  default     = "public-read"
}

variable "versioning_status" {
  description = "Versioning status of your S3 bucket"
  default     = "Suspended"
}

variable "index_document_website" {
  description = "Index document suffix of your website"
  default     = "index.html"
}

variable "error_document_website" {
  description = "Error document key of your website"
  default     = "index.html"
}

variable "force_destroy" {
  description = "Boolean value to force destroy the bucket"
  default     = true
}
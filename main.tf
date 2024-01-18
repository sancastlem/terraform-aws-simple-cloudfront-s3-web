# S3 web with cloudfront
## Bucket
resource "aws_s3_bucket" "web-s3-bucket" {
  bucket = "web-${var.name}-bucket"
  force_destroy = var.force_destroy

  tags = {
    Name        = "web-${var.name}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_acl" "web-s3-bucket-acl" {
  bucket = aws_s3_bucket.web-s3-bucket.id
  acl    = var.acl_name
  depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership, aws_s3_bucket_public_access_block.s3_bucket_acl_public_access_block ]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.web-s3-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_acl_public_access_block" {
  bucket = aws_s3_bucket.web-s3-bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "web-s3-bucket-versioning" {
  bucket = aws_s3_bucket.web-s3-bucket.id
  versioning_configuration {
    status = var.versioning_status
  }
}

resource "aws_s3_bucket_website_configuration" "web-s3-bucket-website-configuration" {
  bucket = aws_s3_bucket.web-s3-bucket.id
  index_document {
    suffix = var.index_document_website
  }

  error_document {
    key = var.error_document_website
  }
}

## Cloudfront
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.web-s3-bucket.bucket_regional_domain_name

    origin_path = var.cloudfront_origin_path
    origin_id   = "s3-${var.name}"
  }

  enabled             = var.cloudfront_status
  is_ipv6_enabled     = true
  comment             = ""
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  aliases             = [var.url]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "s3-${var.name}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    response_headers_policy_id = var.response_headers_policy_id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = var.environment
  }

  viewer_certificate {
    acm_certificate_arn = var.ssl_arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_code         = "404"
    response_code      = "200"
    response_page_path = "/index.html"
  }
}

## Route 53
resource "aws_route53_record" "web-route" {
  zone_id = var.route53_zone_id
  name    = var.url
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

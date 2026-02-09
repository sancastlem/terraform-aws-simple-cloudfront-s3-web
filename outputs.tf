output "get_bucket_name" {
    value = aws_s3_bucket.web-s3-bucket.bucket
}

output "get_cloudfront_url" {
    value = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}

output "get_cloudfront_distribution_id" {
    value = aws_cloudfront_distribution.cloudfront_distribution.id
}
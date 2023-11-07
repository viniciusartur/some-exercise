terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "b1" {
  bucket = "bucket1_${var.env}"
}

resource "aws_s3_bucket_acl" "b1_acl" {
  bucket = aws_s3_bucket.b1.id
  acl    = "private"
}

resource "aws_s3_bucket" "b2" {
  bucket = "bucket2_${var.env}"
}

resource "aws_s3_bucket_acl" "b2_acl" {
  bucket = aws_s3_bucket.b2.id
  acl    = "private"
}

resource "aws_s3_bucket" "b3" {
  bucket = "bucket2_${var.env}"
}

resource "aws_s3_bucket_acl" "b3_acl" {
  bucket = aws_s3_bucket.b3.id
  acl    = "private"
}

locals {
  s3_x_origin_id   = "invalid-origin"
}

resource "aws_cloudfront_distribution" "this" {
  
  enabled = true

  origin {
    origin_id                = local.s3_x_origin_id
    domain_name              = "domain.invalid"
  }
  
  dynamic "origin" {
      for_each = var.settings
      iterator = setting
      content {
        origin_id                = "${setting.value.bucket}-origin"
        domain_name              = "${setting.value.bucket}_${var.env}.s3-website-${var.region}.amazonaws.com"
      }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_x_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

    dynamic "ordered_cache_behavior" {
      for_each = var.settings
      iterator = setting
      content {
        path_pattern     = setting.value.path_pattern
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "${setting.value.bucket}-origin"

        forwarded_values {
          query_string = false

          cookies {
            forward = "none"
          }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
      }
    
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

}

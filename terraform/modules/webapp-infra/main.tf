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
  bucket = "${var.prefix}-bucket1-${var.env}"
}

resource "aws_s3_bucket_policy" "cdn-oac-bucket-policy-b1" {
  bucket = aws_s3_bucket.b1.id
  policy = data.aws_iam_policy_document.s3_bucket_policy_b1.json
}

resource "aws_s3_bucket_policy" "cdn-oac-bucket-policy-b2" {
  bucket = aws_s3_bucket.b2.id
  policy = data.aws_iam_policy_document.s3_bucket_policy_b2.json
}

resource "aws_s3_bucket_policy" "cdn-oac-bucket-policy-b3" {
  bucket = aws_s3_bucket.b3.id
  policy = data.aws_iam_policy_document.s3_bucket_policy_b3.json
}

data "aws_iam_policy_document" "s3_bucket_policy_b1" {
  statement {
    actions = [ "s3:GetObject" ]
    resources = [ "${aws_s3_bucket.b1.arn}/*" ]
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.this.arn]
    }
  }
}

data "aws_iam_policy_document" "s3_bucket_policy_b2" {
  statement {
    actions = [ "s3:GetObject" ]
    resources = [ "${aws_s3_bucket.b2.arn}/*" ]
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.this.arn]
    }
  }
}

data "aws_iam_policy_document" "s3_bucket_policy_b3" {
  statement {
    actions = [ "s3:GetObject" ]
    resources = [ "${aws_s3_bucket.b3.arn}/*" ]
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.this.arn]
    }
  }
}

resource "aws_s3_bucket" "b2" {
  bucket = "${var.prefix}-bucket2-${var.env}"
}

resource "aws_s3_bucket" "b3" {
  bucket = "${var.prefix}-bucket3-${var.env}"
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "iofinnet-exercise"
  description                       = "iofinnet exercise"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  
  enabled = true
  
  dynamic "origin" {
      for_each = var.settings
      iterator = setting
      content {
        origin_id                = "${setting.value.bucket}-origin"
        domain_name              = "${var.prefix}-${setting.value.bucket}-${var.env}.s3.${var.region}.amazonaws.com"
        origin_access_control_id = aws_cloudfront_origin_access_control.default.id
      }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "bucket1-origin"

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
      locations        = ["US", "CA", "GB", "DE", "PT"]
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

}

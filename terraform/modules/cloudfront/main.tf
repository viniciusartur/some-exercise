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
        origin_id                = "${setting.key}-origin"
        domain_name              = "${var.prefix}-${setting.key}-${var.env}.s3.${var.region}.amazonaws.com"
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
        path_pattern     = setting.value
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "${setting.key}-origin"

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

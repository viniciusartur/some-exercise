module "bucket1" {
  source         = "../bucket"

  for_each = var.settings

  bucket_name    = "${var.prefix}-${each.key}-${var.env}"
  cloudfront_arn = module.cloudfront_distro.cloudfront_arn
}

module "cloudfront_distro" {
  source         = "../cloudfront"
  settings       = var.settings
  prefix         = var.prefix
  env            = var.env
  region         = var.region
}

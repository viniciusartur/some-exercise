variable "region" {
  type = string
  default = "us-east-1"
}

variable "prefix" {
  type = string
  default = "xtesttest2x"
}

variable "env" {
  type = string
}

variable "settings" {
  default = [
    {
      path_pattern = "/auth/*"
      bucket    = "bucket1"
    },
    {
      path_pattern = "/info/*"
      bucket    = "bucket2"
    },
    {
      path_pattern = "/customers/*"
      bucket    = "bucket3"
    }
  ]
}

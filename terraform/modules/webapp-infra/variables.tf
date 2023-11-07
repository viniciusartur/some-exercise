variable "region" {
  type = string
  default = "ap-southeast-1"
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

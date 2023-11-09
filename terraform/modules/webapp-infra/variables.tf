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
  default = {
    bucket1 = "/auth/*"
    bucket2 = "/info/*"
    bucket3 = "/customers/*"
  }
}

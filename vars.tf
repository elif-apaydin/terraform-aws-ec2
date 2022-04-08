variable "app_tags" {
  type = string
}
variable "region" {
  type = string
}

variable "ec2type" {
  type = string
}

variable "subnet" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "keypair" {
  type = string
}

variable "instanceprofile" {
  type = string
}

variable "discsize" {
  type = number
}

variable "sgports" {
  type = number
}

variable "opsgeniesnstopic" {
  type = string
}

variable "emailsnstopic" {
  type = string
}

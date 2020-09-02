variable "aws_access_key" {
  # to be obtained dynamically
}

variable "aws_secret_key" {
  # to be obtained dynamically
}

variable "aws_region" {
  default = "ap-south-1"
}

variable "basic_ami" {
  default = "<AMI ID>"
}

variable "basic_sg" {
  default = "<SG ID>"
}

variable "office_address" {
  # to be obtained dynamically
}

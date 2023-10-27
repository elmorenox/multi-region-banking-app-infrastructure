variable "vpc_names" {
  type    = list(string)
  default = ["vpc-us-east-1", "vpc-us-west-2"]
}

variable "public_subnet_count" {
  type    = number
  default = 2
}

variable "vpc_regions" {
  type    = list(string)
  default = ["us-east-1", "us-west-2"]
}

variable "ec2_names" {
  type    = list(string)
  default = ["appserver-1", "appserver-2", "appserver-3", "appserver-4"]
}

variable "public_subnet_azs" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-west-2a",
    "us-west-2b"
  ]
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
  ]
}

variable "key_names" {
  type = list(string)
  default = [
    "LuisMoreno873key",
    "west-key"
  ]
}

variable "us_east_region" {
  description = "AWS region for the us-east VPC"
  type        = string
  default     = "us-east-1"
}

variable "us_west_region" {
  description = "AWS region for the us-west VPC"
  type        = string
  default     = "us-west-2"
}

variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

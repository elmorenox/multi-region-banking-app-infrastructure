provider "aws" {
  region = var.us_east_region
  access_key  = var.aws_access_key
  secret_key  = var.aws_secret_key
}

provider "aws" {
  alias  = "us_west"
  access_key  = var.aws_access_key
  secret_key  = var.aws_secret_key  
  region = var.us_west_region
}
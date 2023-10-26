provider "aws" {
    region = var.us_east_region
}

provider "aws" {
    alias = "us_west"
    region = var.us_west_region
}
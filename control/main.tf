provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "dl-terraform-state-db"
    versioning {
        enabled = true
    }
    lifecycle {
        prevent_destroy = true
    }
}


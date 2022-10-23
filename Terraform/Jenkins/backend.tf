terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
    backend "s3" {
        encrypt = true
        bucket = var.bucketname
        dynamodb_table = var.dyntable
        key = var.statefile
        region = var.region
    }
}
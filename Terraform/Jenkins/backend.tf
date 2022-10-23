terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
    backend "s3" {
        encrypt = true
        bucket = "remote-statefile"
        dynamodb_table = "state-table"
        key = "terraform.tfstate"
        region = "ap-northeast-1"
    }
}
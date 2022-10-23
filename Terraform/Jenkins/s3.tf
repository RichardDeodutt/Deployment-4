resource "aws_s3_bucket" "bucket" {
    
    bucket = var.bucketname
    acl = var.bucketacl
}
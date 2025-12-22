
# Random string to ensure unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# The S3 Landing Zone Bucket
resource "aws_s3_bucket" "landing_zone" {
  bucket = "dms-landing-zone-${random_id.bucket_suffix.hex}"
  force_destroy = true # Easy cleanup for demo
}

# Block public access (Best Practice)
resource "aws_s3_bucket_public_access_block" "landing_zone" {
  bucket = aws_s3_bucket.landing_zone.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

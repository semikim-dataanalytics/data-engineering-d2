# IAM Role for DMS to access S3
resource "aws_iam_role" "dms_s3_role" {
  name = "dms-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "dms_s3_policy" {
  name = "dms-s3-access-policy"
  role = aws_iam_role.dms_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject", 
          "s3:PutObjectTagging",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.landing_zone.arn,
          "${aws_s3_bucket.landing_zone.arn}/*"
        ]
      }
    ]
  })
}

resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_s3_bucket" "mongo_backup" {
  bucket = "${var.project_name}-db-backups-${random_string.bucket_suffix.result}"
  tags   = local.tags
}

resource "aws_s3_bucket_public_access_block" "mongo_backup" {
  bucket = aws_s3_bucket.mongo_backup.id

  block_public_acls       = false # 의도된 보안 리스크 Public access 차단 해제
  block_public_policy     = false # 의도된 보안 리스크  
  ignore_public_acls      = false # 의도된 보안 리스크
  restrict_public_buckets = false # 의도된 보안 리스크
}

resource "aws_s3_bucket_policy" "mongo_backup_public" {
  bucket     = aws_s3_bucket.mongo_backup.id
  depends_on = [aws_s3_bucket_public_access_block.mongo_backup]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicListBucket"
        Effect    = "Allow"
        Principal = "*" # 의도된 보안 리스크 누구나 목록 조회 가능
        Action    = ["s3:ListBucket"]
        Resource  = aws_s3_bucket.mongo_backup.arn
      },
      {
        Sid       = "PublicReadObject"
        Effect    = "Allow"
        Principal = "*" # 의도된 보안 리스크 누구나 객체 읽기 가능
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.mongo_backup.arn}/*"
      }
    ]
  })
}
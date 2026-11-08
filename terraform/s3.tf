# Generate a unique bucket name suffix
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create S3 bucket
resource "aws_s3_bucket" "app_storage" {
  bucket = "cloud-deployment-storage-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "cloud-deployment-storage"
    Environment = "Development"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}
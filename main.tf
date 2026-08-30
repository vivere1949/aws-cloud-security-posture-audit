provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "cloud-security-terraform-demo-2026"
}

resource "aws_security_group" "demo_sg" {
  name        = "demo-security-group"
  description = "Security group for Checkov demo"

  ingress {
    description = "SSH restricted to trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.0.2.10/32"]
  }

  egress {
    description = "Allow HTTPS outbound traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket_public_access_block" "demo_bucket" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "demo_bucket" {
  bucket = aws_s3_bucket.demo_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_kms_alias" "s3_key" {
  name = "alias/cloud-security-s3-key"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo_bucket" {
  bucket = aws_s3_bucket.demo_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = data.aws_kms_alias.s3_key.target_key_arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}

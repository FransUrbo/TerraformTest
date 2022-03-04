resource "aws_s3_bucket" "s3-outgoing" {
  bucket			= "test-turbo-outgoing"

  tags = {
    Name			= "test-turbo-outgoing"
    environment			= "core"
    service			= "storage"
  }
}

resource "aws_s3_bucket_acl" "s3-outgoing" {
  bucket			= aws_s3_bucket.s3-outgoing.id
  acl				= "private"
}

resource "aws_s3_bucket_versioning" "s3-outgoing" {
  bucket			= aws_s3_bucket.s3-outgoing.id
  versioning_configuration {
    status			= "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3-outgoing" {
  bucket			= aws_s3_bucket.s3-outgoing.id

  rule {
    id				= "root"
    status			= "Enabled"

    filter {
      prefix			= "/"
    }

    transition {
      days			= 30
      storage_class		= "STANDARD_IA"
    }

    transition {
       days			= 60
       storage_class		= "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days		= 30
      storage_class		= "STANDARD_IA"
    }

    noncurrent_version_transition {
       noncurrent_days		= 60
       storage_class		= "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days		= 90
    }
  }
}

resource "aws_s3_bucket_policy" "s3-outgoing" {
  bucket			= "${aws_s3_bucket.s3-outgoing.id}"
  policy			= <<BUCKET_POLICY_OUTGOING
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
            "AWS": [
                "arn:aws:iam::${var.account_id}:user/turbo"
            ]
        },
        "Action": "s3:*",
        "Resource": [
            "${aws_s3_bucket.s3-outgoing.arn}",
            "${aws_s3_bucket.s3-outgoing.arn}/*"
        ]
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.s3-outgoing.arn}/*",
      ],
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.account_id}:role/lambda"
        ]
      }
    }
  ]
}
BUCKET_POLICY_OUTGOING
}

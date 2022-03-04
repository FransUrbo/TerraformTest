resource "aws_s3_bucket" "s3-incoming" {
  bucket			= "test-turbo-incoming"

  tags = {
    Name			= "test-turbo-incoming"
    environment			= "core"
    service			= "storage"
  }
}

resource "aws_s3_bucket_acl" "s3-incoming" {
  bucket			= aws_s3_bucket.s3-incoming.id
  acl				= "private"
}

resource "aws_s3_bucket_versioning" "s3-incoming" {
  bucket			= aws_s3_bucket.s3-incoming.id
  versioning_configuration {
    status			= "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3-incoming" {
  bucket			= aws_s3_bucket.s3-incoming.id

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

resource "aws_s3_bucket_policy" "s3-incoming" {
  bucket			= "${aws_s3_bucket.s3-incoming.id}"
  policy			= <<BUCKET_POLICY_INCOMING
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
            "${aws_s3_bucket.s3-incoming.arn}",
            "${aws_s3_bucket.s3-incoming.arn}/*"
        ]
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.s3-incoming.arn}/*",
      ],
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.account_id}:role/lambda"
        ]
      }
    }
  ]
}
BUCKET_POLICY_INCOMING
}

resource "aws_s3_bucket_notification" "s3-incoming" {
  bucket			= aws_s3_bucket.s3-incoming.id

  lambda_function {
    lambda_function_arn		= aws_lambda_function.s3-cleanup.arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_suffix       = ".jpg"
  }

  depends_on = [aws_lambda_permission.s3-incoming-cleanup]
}

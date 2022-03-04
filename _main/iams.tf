resource "aws_iam_role" "lambda" {
  name				= "lambda"
  assume_role_policy		= <<ROLE_LAMBDA
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "s3.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.account_id}:role/lambda"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
ROLE_LAMBDA
}

resource "aws_lambda_function" "s3-cleanup" {
  function_name			= "autoscaling_event_update_route53-cleanup"
  description			= "A function that cleans up meta data from an image file."

  filename			= "${var.s3-cleanup}"
  source_code_hash		= "${filebase64sha256("${var.s3-cleanup}")}"
  handler			= "s3-cleanup.handler"

  runtime			= "python3.6"
  memory_size			= 128
  timeout			= 10

  role				= "${aws_iam_role.lambda.arn}"

  vpc_config {
    subnet_ids           = [
      "${aws_subnet.main_private.0.id}",
      "${aws_subnet.main_private.1.id}",
      "${aws_subnet.main_private.2.id}"
    ]

    security_group_ids     = [
      "${aws_default_security_group.main_default.id}"
    ]
  }
}

resource "aws_lambda_permission" "s3-incoming-cleanup" {
  function_name			= aws_lambda_function.s3-cleanup.arn
  statement_id			= "AllowExecutionFromS3Bucket"
  action			= "lambda:InvokeFunction"
  principal			= "s3.amazonaws.com"
  source_arn			= aws_s3_bucket.s3-incoming.arn
}

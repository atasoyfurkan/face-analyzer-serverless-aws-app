# S3 bucket configuration
resource "aws_s3_bucket" "upload_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_cors_configuration" "upload_bucket_cors" {
  bucket = aws_s3_bucket.upload_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_versioning" "upload_bucket_versioning" {
  bucket = aws_s3_bucket.upload_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


# S3 access to Lambda
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = var.invoke_lambda_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = var.invoke_lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.lambda_trigger_filter_prefix
    filter_suffix       = var.lambda_trigger_filter_suffix
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}

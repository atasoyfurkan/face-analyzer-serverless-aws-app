locals {
  application_name     = "FaceAnalyzer"
  upload_function_name = "${local.application_name}-ImageUploadHandler"
}

module "lambda" {
  source = "./modules/lambda"

  function_name      = local.upload_function_name
  handler            = "image_upload_handler.lambda_handler"
  runtime            = "python3.8"
  filename           = "../lambda_functions/image_upload_handler"
  region             = var.region
  s3_bucket_arn      = module.s3.bucket_arn
  dynamodb_table_arn = module.dynamo_db.table_arn
}

module "api_gateway" {
  source = "./modules/api_gateway"

  api_name             = "${local.application_name}-RestAPI"
  lambda_invoke_arn    = module.lambda.lambda_arn
  lambda_function_name = local.upload_function_name
  region               = var.region
  stage_name           = "v1"
}

module "s3" {
  source = "./modules/s3"

  bucket_name                  = lower("${local.application_name}-UploadBucket-${var.region}-Atasoy")
  lambda_invoke_arn            = module.lambda.lambda_arn
  lambda_trigger_filter_prefix = "uploads/"
  lambda_trigger_filter_suffix = ".jpg"
}

module "dynamo_db" {
  source = "./modules/dynamo_db"

  table_name = "${local.application_name}-ImageData"
}

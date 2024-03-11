locals {
  application_name          = "FaceAnalyzer"
  image_upload_handler_name = "${local.application_name}-ImageUploadHandler"
  image_processer_name      = "${local.application_name}-ImageProcesser"
  dynamo_db_table_name      = "${local.application_name}-ImageData"
}

module "lambda_image_upload_handler" {
  source = "./modules/lambda/image_upload_handler"

  function_name       = local.image_upload_handler_name
  region              = var.region
  s3_bucket_arn       = module.s3.bucket_arn
  dynamodb_table_arn  = module.dynamo_db.table_arn
  dynamodb_table_name = local.dynamo_db_table_name
  sqs_queue_arn       = module.sqs_image_processing.queue_arn
  sqs_queue_url       = module.sqs_image_processing.queue_url
}

module "lambda_image_processer" {
  source = "./modules/lambda/image_processer"

  function_name       = local.image_processer_name
  region              = var.region
  s3_bucket_arn       = module.s3.bucket_arn
  dynamodb_table_arn  = module.dynamo_db.table_arn
  dynamodb_table_name = local.dynamo_db_table_name
  sqs_queue_arn       = module.sqs_image_processing.queue_arn
}


module "api_gateway" {
  source = "./modules/api_gateway"

  api_name             = "${local.application_name}-RestAPI"
  invoke_lambda_arn    = module.lambda_image_upload_handler.lambda_arn
  lambda_function_name = local.image_upload_handler_name
  region               = var.region
  stage_name           = "v1"
}

module "s3" {
  source = "./modules/s3"

  bucket_name                  = lower("${local.application_name}-UploadBucket-${var.region}-Atasoy")
  invoke_lambda_arn            = module.lambda_image_upload_handler.lambda_arn
  lambda_trigger_filter_prefix = "uploads/"
  lambda_trigger_filter_suffix = ".jpg"
}

module "dynamo_db" {
  source = "./modules/dynamo_db"

  table_name = local.dynamo_db_table_name
}

module "sqs_image_processing" {
  source = "./modules/sqs"

  queue_name         = "${local.application_name}-ImageProcessingQueue"
  source_lambda_arn  = module.lambda_image_upload_handler.lambda_arn
  trigger_lambda_arn = module.lambda_image_processer.lambda_arn
}

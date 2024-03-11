resource "aws_sqs_queue" "image_processing_queue" {
  name                      = var.queue_name
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
}

resource "aws_sqs_queue_policy" "image_processing_queue_policy" {
  queue_url = aws_sqs_queue.image_processing_queue.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Effect : "Allow",
      Principal : "*",
      Action : "SQS:SendMessage",
      Resource : aws_sqs_queue.image_processing_queue.arn,
      Condition : {
        ArnEquals : {
          "aws:SourceArn" : var.source_lambda_arn,
        }
      }
    }]
  })
}

# Lambda trigger
resource "aws_lambda_event_source_mapping" "sqs_event_source_mapping" {
  event_source_arn = aws_sqs_queue.image_processing_queue.arn
  function_name    = var.trigger_lambda_arn
  batch_size       = 10
}

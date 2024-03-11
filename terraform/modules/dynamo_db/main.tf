resource "aws_dynamodb_table" "image_data" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "fileId"

  attribute {
    name = "fileId"
    type = "S"
  }

  tags = {
    Name = "ImageData"
  }
}

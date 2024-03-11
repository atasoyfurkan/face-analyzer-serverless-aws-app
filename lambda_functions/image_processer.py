import os
import json
import boto3
from botocore.exceptions import ClientError
import logging

logger = logging.getLogger()
logger.setLevel(os.getenv('LOGGING_LEVEL', 'WARNING'))

s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')


def get_env_variables():
    TABLE_NAME = os.environ['TABLE_NAME']

    if not TABLE_NAME:
        raise ValueError("Environment variables TABLE_NAME is required.")

    return TABLE_NAME


def process_sqs_message(message):
    # Extract S3 object information from the SQS message
    image_data = json.loads(message['body'])
    bucket_name = image_data['s3Bucket']
    object_key = image_data['s3Key']

    # Perform your S3 object processing here
    logger.info(f"Processing file from bucket {bucket_name} with key {object_key}")

    return "WILL BE FILLED"


def update_dynamodb(table_name, item):
    table = dynamodb.Table(table_name)
    try:
        response = table.put_item(Item=item)
        logger.info(f"Item written to DynamoDB: {response}")

        return response
    except ClientError as e:
        logger.error(f"Error writing to DynamoDB: {e}")
        return None


def lambda_handler(event, context):
    logger.info(f"Received event: {event}")
    logger.info(f"Environment variables: {os.environ}")

    TABLE_NAME = get_env_variables()

    for record in event['Records']:
        updated_image_data = process_sqs_message(record)

        # response = update_dynamodb(TABLE_NAME, updated_image_data)

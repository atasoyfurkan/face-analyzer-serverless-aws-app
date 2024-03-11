import os
import json
import boto3
from botocore.exceptions import ClientError
from datetime import datetime
import logging

logger = logging.getLogger()
LOGGING_LEVEL = os.environ.get('LOGGING_LEVEL', 'WARNING')
logger.setLevel(logging.getLevelName(LOGGING_LEVEL))

dynamodb = boto3.resource('dynamodb')
s3_client = boto3.client('s3')
sqs_client = boto3.client('sqs')


def get_env_variables():
    TABLE_NAME = os.environ['TABLE_NAME']
    SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']

    if not TABLE_NAME or not SQS_QUEUE_URL:
        raise ValueError("Environment variables TABLE_NAME and SQS_QUEUE_URL are required.")

    return TABLE_NAME, SQS_QUEUE_URL


def get_file_metadata(bucket, key):
    try:
        response = s3_client.head_object(Bucket=bucket, Key=key)
        logger.info(f"File metadata: {response}")

        return {
            'fileType': response['ContentType'],
            'fileSize': response['ContentLength'],
        }
    except ClientError as e:
        logger.error(f"Error getting file metadata: {e}")
        return None


def write_to_dynamodb(table_name, item):
    table = dynamodb.Table(table_name)
    try:
        response = table.put_item(Item=item)
        logger.info(f"Item written to DynamoDB: {response}")

        return response
    except ClientError as e:
        logger.error(f"Error writing to DynamoDB: {e}")
        return None


def enqueue_message(queue_url, message_body):
    try:
        response = sqs_client.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(message_body)
        )
        logger.info(f"Message sent to SQS: {response}")
    except ClientError as e:
        logger.error(f"Error sending message to SQS: {e}")
        return None


def lambda_handler(event, context):
    logger.info(f"Received event: {event}")
    logger.info(f"Environment variables: {os.environ}")

    TABLE_NAME, SQS_QUEUE_URL = get_env_variables()

    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']

        metadata = get_file_metadata(bucket_name, object_key)
        if not metadata:
            continue

        item = {
            'fileId': object_key,
            's3Bucket': bucket_name,
            's3Key': object_key,
            'fileType': metadata['fileType'],
            'fileSize': metadata['fileSize'],
            'uploadTimestamp': datetime.utcnow().isoformat(),
        }

        response = write_to_dynamodb(TABLE_NAME, item)
        if not response:
            continue

        enqueue_message(SQS_QUEUE_URL, item)

    logger.info("Processing complete.")

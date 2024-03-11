import json
import boto3
from botocore.exceptions import ClientError
from datetime import datetime
import logging

logger = logging.getLogger()

# Initialize clients outside the handler to take advantage of connection reuse
dynamodb = boto3.resource('dynamodb')
s3_client = boto3.client('s3')

TABLE_NAME = 'FaceAnalyzer-ImageData'


def get_file_metadata(bucket, key):
    try:
        response = s3_client.head_object(Bucket=bucket, Key=key)
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
        return response
    except ClientError as e:
        logger.error(f"Error writing to DynamoDB: {e}")
        return None


def lambda_handler(event, context):
    print(f"Received event: {event}")

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

    return {
        'statusCode': 200,
        'body': json.dumps('Processing complete.')
    }

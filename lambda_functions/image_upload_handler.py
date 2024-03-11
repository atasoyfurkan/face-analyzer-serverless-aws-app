import json


def lambda_handler(event, context):
    print(f"Event: {event}, Context: {context}")

    return {
        'statusCode': 200,
        'body': json.dumps('Hello, Lambda')
    }

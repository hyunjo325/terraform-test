import json
import urllib.request
import os

def lambda_handler(event, context):
    webhook_url = os.environ['SLACK_WEBHOOK_URL']
    message = {
        'text': f":rotating_light: *CloudWatch Alarm Triggered!*\n\n```{json.dumps(event, indent=2)}```"
    }

    data = json.dumps(message).encode("utf-8")

    req = urllib.request.Request(
        webhook_url,
        data=data,
        headers={'Content-Type': 'application/json'}
    )

    try:
        response = urllib.request.urlopen(req)
        return {
            'statusCode': response.getcode(),
            'body': response.read().decode("utf-8")
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': str(e)
        }

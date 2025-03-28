import json
import os
import urllib.request

def lambda_handler(event, context):
    webhook_url = os.environ['SLACK_WEBHOOK_URL']

    for record in event['Records']:
        sns = record['Sns']
        raw_message = sns['Message']
        
        try:
            alarm = json.loads(raw_message)
        except json.JSONDecodeError:
            alarm = {"raw_message": raw_message}

        alarm_name = alarm.get('AlarmName', '알 수 없음')
        new_state = alarm.get('NewStateValue', 'UNKNOWN')
        reason = alarm.get('NewStateReason', '사유 없음')
        region = alarm.get('Region', '지역 정보 없음')

        trigger = alarm.get('Trigger', {})
        metric_name = trigger.get('MetricName', '지표 정보 없음')
        cluster_name = "알 수 없음"
        service_name = "알 수 없음"

        for d in trigger.get('Dimensions', []):
            if d['name'] == 'ClusterName':
                cluster_name = d['value']
            elif d['name'] == 'ServiceName':
                service_name = d['value']

        # Slack에 보낼 메시지 구성
        slack_text = (
            f"*🚨 CloudWatch 알람 발생!*\n"
            f"*알람 이름:* `{alarm_name}`\n"
            f"*상태:* `{new_state}`\n"
            f"*서비스:* `{service_name}`\n"
            f"*클러스터:* `{cluster_name}`\n"
            f"*지표:* `{metric_name}`\n"
            f"*사유:* {reason}\n"
            f"*리전:* {region}"
        )

        payload = json.dumps({"text": slack_text}).encode("utf-8")

        req = urllib.request.Request(
            webhook_url,
            data=payload,
            headers={"Content-Type": "application/json"}
        )

        try:
            with urllib.request.urlopen(req) as response:
                print("Slack 전송 성공", response.status)
        except Exception as e:
            print("Slack 전송 실패", e)

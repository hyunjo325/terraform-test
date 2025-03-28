import json
import os
import urllib.request

def lambda_handler(event, context):
    webhook_url = os.environ['SLACK_WEBHOOK_URL']

    for record in event['Records']:
        sns = record['Sns']
        raw_message = sns['Message']
        alarm = json.loads(raw_message)  # SNS 내부 메시지도 JSON 파싱

        alarm_name = alarm.get('AlarmName', '알 수 없음')
        new_state = alarm.get('NewStateValue', 'UNKNOWN')
        reason = alarm.get('NewStateReason', '사유 없음')
        region = alarm.get('Region', '지역 정보 없음')

        metric_info = alarm.get('Trigger', {})
        metric_name = metric_info.get('MetricName', '지표 정보 없음')
        namespace = metric_info.get('Namespace', '')
        dimensions = metric_info.get('Dimensions', [])

        # ClusterName과 ServiceName 추출
        cluster_name = next((d["value"] for d in dimensions if d["name"] == "ClusterName"), "알 수 없음")
        service_name = next((d["value"] for d in dimensions if d["name"] == "ServiceName"), "알 수 없음")

        message = f"""
*🚨 CloudWatch 경보 발생!*
*알람 이름:* `{alarm_name}`
*상태 변경:* `{new_state}`
*서비스:* `{service_name}`
*클러스터:* `{cluster_name}`
*지표:* `{metric_name}`
*이유:* {reason}
*리전:* {region}
"""

        payload = json.dumps({"text": message}).encode("utf-8")

        req = urllib.request.Request(
            webhook_url,
            data=payload,
            headers={"Content-Type": "application/json"}
        )

        try:
            with urllib.request.urlopen(req) as response:
                print("Slack 알림 전송 성공:", response.status)
        except Exception as e:
            print("Slack 알림 전송 실패:", e)

variable "alarm_name" {
  type        = string
  description = "이 알람의 이름"
}

variable "namespace" {
  type        = string
  description = "메트릭 네임스페이스 (예: AWS/ECS, AWS/EC2 등)"
}

variable "metric_name" {
  type        = string
  description = "모니터링할 메트릭 이름"
}

variable "comparison_operator" {
  type        = string
  description = "비교 연산자 (예: GreaterThanThreshold)"
}

variable "threshold" {
  type        = number
  description = "임계값"
}

variable "period" {
  type        = number
  description = "측정 간격 (초 단위)"
}

variable "evaluation_periods" {
  type        = number
  description = "평가 주기"
}

variable "statistic" {
  type        = string
  default     = "Average"
}

variable "dimensions" {
  type        = map(string)
  description = "메트릭에 적용할 차원 (예: { ClusterName = ..., ServiceName = ... })"
}

variable "alarm_actions" {
  type        = list(string)
  description = "알람 발생 시 실행할 SNS 주제 ARN 목록"
  default     = []
}

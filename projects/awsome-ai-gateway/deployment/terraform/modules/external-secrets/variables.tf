# Copyright 2026 © Amazon.com and Affiliates: This deliverable is considered Developed Content as defined in the AWS Service Terms.

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "irsa_role_arn" {
  description = "IRSA role ARN (irsa 모듈의 external_secrets_role_arn)"
  type        = string
}

variable "aws_region" {
  type = string
}

variable "chart_version" {
  description = "external-secrets Helm chart 버전"
  type        = string
  default     = "0.10.4"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "webhook_port" {
  description = "ESO webhook 컨테이너 포트. Fargate 에서 kubelet(10250) 과 충돌하므로 10250 이외 값 필수"
  type        = number
  default     = 9443
  validation {
    condition     = var.webhook_port != 10250
    error_message = "webhook_port 는 Fargate kubelet 포트 10250 과 겹칠 수 없습니다."
  }
}

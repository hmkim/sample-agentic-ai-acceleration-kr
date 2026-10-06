# Copyright 2026 © Amazon.com and Affiliates: This deliverable is considered Developed Content as defined in the AWS Service Terms.

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_version" {
  # 기본값을 일부러 두지 않는다(=필수). 환경 루트가 유일한 진실이어야 하기 때문이다 —
  # 기본값이 있으면 호출부가 값을 빼먹어도 plan 이 조용히 통과하고, 실제로 이 모듈은
  # module 1.29 / env 1.30 / 라이브 1.31 의 3중 불일치 상태로 방치돼 있었다.
  # 호출부는 2곳뿐이다(environments/llm-gateway-{dev,prod}/main.tf).
  # nullable = false: 기본값이 없어도 명시적 `cluster_version = null` 은 타입 검사를
  # 통과해 downstream 으로 흘러간다. 이 키워드가 있으면 "required variable may not be
  # set to null" 로 plan 단계에서 크게 실패한다(조용한 null 전파 차단).
  description = "EKS Kubernetes 버전 (환경 루트에서 필수 전달)"
  type        = string
  nullable    = false
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  description = "Fargate Pod 배치용 private subnet IDs (AZ 3개 이상 권장)"
  type        = list(string)
}

variable "public_access_cidrs" {
  description = "dev에서 kubectl 접근 허용 CIDR"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "application_namespace" {
  description = "LLM Gateway가 설치될 네임스페이스"
  type        = string
  default     = "llm-gateway"
}

variable "addon_versions" {
  description = <<-EOT
    EKS add-on 버전 override. 각 키가 null(또는 미지정)이면 모듈이
    data.aws_eks_addon_version(most_recent, kubernetes_version = cluster_version) 로
    **클러스터 버전에 맞는 최신 호환 버전을 자동 해석**한다.
    상수 핀은 클러스터 minor 를 올릴 때 미지원 버전이 되어 apply 가
    InvalidParameterException 으로 죽는 사고(2026-10-06 재현)를 막기 위해 기본은 자동이다.
    특정 버전을 고정해야 할 때만 키 단위로 명시한다.
  EOT
  type = object({
    coredns    = optional(string)
    kube_proxy = optional(string)
    vpc_cni    = optional(string)
  })
  default  = {}
  nullable = false
}

variable "access_entries" {
  description = "EKS Access Entries — 관리자/CI 계정 → RBAC role 매핑"
  type        = any
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}

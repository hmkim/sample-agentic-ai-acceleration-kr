# Copyright 2026 © Amazon.com and Affiliates: This deliverable is considered Developed Content as defined in the AWS Service Terms.

# ==============================================================================
# External Secrets Operator 설치
# ------------------------------------------------------------------------------
# - Helm chart 로 ESO 설치 (CRD 포함)
# - ClusterSecretStore 생성은 별도 단계 (install-eks.sh 의 kubectl apply) 에서 처리.
#   Helm 이 CRD 등록과 CR 생성을 같은 apply 로 시도해 실패하는 문제 회피.
# ==============================================================================

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.chart_version
  namespace        = "external-secrets"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.irsa_role_arn
  }
  set {
    name  = "replicaCount"
    value = var.environment == "prod" ? "2" : "1"
  }
  # Fargate 에서는 Pod IP == 노드 IP 이고 kubelet 이 10250 을 점유하므로, 차트 기본값
  # webhook.port=10250 이면 API server → webhook 호출이 kubelet 에 닿아
  # "x509: certificate is valid for fargate-ip-… not external-secrets-webhook.external-secrets.svc"
  # 로 실패한다(종전 troubleshooting 의 'cert SAN 불일치' 증상). 다른 포트로 회피.
  set {
    name  = "webhook.port"
    value = tostring(var.webhook_port)
  }

  atomic          = true
  cleanup_on_fail = true
  timeout         = 600
  wait            = true
}

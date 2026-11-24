#!/usr/bin/env bash
# 배포 스텁: 실제 배포 명령(예: aws/gcloud/ssh/helm)으로 교체하세요.
set -euo pipefail
ENV_NAME="${1:?environment required}"
SHA="${2:?sha required}"
echo "Deploying ${SHA} to ${ENV_NAME} ..."
# TODO: 실제 배포 로직
echo "Done."

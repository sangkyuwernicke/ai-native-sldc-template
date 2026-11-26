#!/usr/bin/env bash
# 배포 스크립트: 대상은 환경 변수 DEPLOY_TARGET 으로 선택한다 (GitHub Environments 의 Variables 로 설정).
#   DEPLOY_TARGET=vercel  -> Vercel CLI 로 배포 (필수: VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID)
#   (미설정/stub)          -> 로그만 출력
# 사용: ./scripts/deploy.sh <staging|production> <git-sha>
set -euo pipefail

ENV_NAME="${1:?environment required (staging|production)}"
SHA="${2:?sha required}"
TARGET="${DEPLOY_TARGET:-stub}"

require() {
  local missing=0
  for v in "$@"; do
    if [ -z "${!v:-}" ]; then echo "::error::환경 변수 $v 가 설정되지 않았습니다 (환경: $ENV_NAME)" >&2; missing=1; fi
  done
  [ "$missing" -eq 0 ] || exit 1
}

case "$TARGET" in
  vercel)
    require VERCEL_TOKEN VERCEL_ORG_ID VERCEL_PROJECT_ID
    VERCEL="npx --yes vercel@${VERCEL_CLI_VERSION:-latest}"
    # production 환경은 --prod, 그 외(staging)는 preview 배포
    if [ "$ENV_NAME" = "production" ]; then
      VERCEL_ENV="production"; PROD_FLAG="--prod"
    else
      VERCEL_ENV="preview"; PROD_FLAG=""
    fi
    echo "Deploying ${SHA} to Vercel (${VERCEL_ENV}) ..."
    $VERCEL pull --yes --environment="$VERCEL_ENV" --token="$VERCEL_TOKEN"
    $VERCEL build $PROD_FLAG --token="$VERCEL_TOKEN"
    URL=$($VERCEL deploy --prebuilt $PROD_FLAG --token="$VERCEL_TOKEN" \
      --meta githubCommitSha="$SHA" --meta githubEnvironment="$ENV_NAME")
    echo "Deployed: $URL"
    [ -z "${GITHUB_OUTPUT:-}" ] || echo "url=$URL" >> "$GITHUB_OUTPUT"
    ;;
  stub)
    echo "[stub] Deploying ${SHA} to ${ENV_NAME} (DEPLOY_TARGET 미설정)"
    ;;
  *)
    echo "::error::지원하지 않는 DEPLOY_TARGET: $TARGET" >&2
    exit 1
    ;;
esac

#!/usr/bin/env bash
# 배포 스크립트: 대상은 환경 변수 DEPLOY_TARGET 으로 선택한다 (GitHub Environments 의 Variables 로 설정).
#   DEPLOY_TARGET=vercel  -> Vercel CLI 로 배포 (필수: VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID, VERCEL_CLI_VERSION)
#   (미설정/stub)          -> 로그만 출력 (staging 에서만 허용, production 은 실패)
# 사용: ./scripts/deploy.sh <staging|production> <git-sha>
set -euo pipefail

ENV_NAME="${1:?environment required (staging|production)}"
SHA="${2:?sha required}"
TARGET="${DEPLOY_TARGET:-stub}"

# 오타(예: prod)로 의도치 않은 preview 배포가 되는 것을 막는다
case "$ENV_NAME" in
  staging|production) ;;
  *) echo "::error::environment 는 staging 또는 production 이어야 합니다: $ENV_NAME" >&2; exit 1 ;;
esac

# fail-closed: production 에서 DEPLOY_TARGET 이 비어 있으면 아무것도 배포하지 않고 성공하는 일이 없도록 실패시킨다
if [ "$TARGET" = "stub" ] && [ "$ENV_NAME" = "production" ]; then
  echo "::error::production 에서 DEPLOY_TARGET 이 설정되지 않았습니다 (stub 은 production 에서 허용되지 않음)" >&2
  exit 1
fi

require() {
  local missing=0
  for v in "$@"; do
    if [ -z "${!v:-}" ]; then echo "::error::환경 변수 $v 가 설정되지 않았습니다 (환경: $ENV_NAME)" >&2; missing=1; fi
  done
  [ "$missing" -eq 0 ] || exit 1
}

case "$TARGET" in
  vercel)
    require VERCEL_TOKEN VERCEL_ORG_ID VERCEL_PROJECT_ID VERCEL_CLI_VERSION
    # CLI 버전은 반드시 고정한다 (토큰과 함께 실행되므로 latest 금지, 공급망 위험)
    VERCEL="npx --yes vercel@${VERCEL_CLI_VERSION}"
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

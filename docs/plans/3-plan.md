# plan: 환경 변수 기반 Vercel 배포

- 목표: 배포 대상을 GitHub Environments 변수로 선택하고, 첫 대상으로 Vercel 지원
- 변경: `scripts/deploy.sh`(DEPLOY_TARGET 분기), `deploy.yml`/`rollback.yml`(env 전달, setup-node)
- 환경별 값(Environment 단위로 등록)
  - Variables: `DEPLOY_TARGET=vercel`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`
  - Secrets: `VERCEL_TOKEN`
- staging = Vercel preview, production = `--prod`
- 위험도: risk:high (.github/ 및 배포 스크립트 변경) - 사람 리뷰 필수
- 롤백: rollback 워크플로로 이전 SHA 재배포 (같은 스크립트 사용)

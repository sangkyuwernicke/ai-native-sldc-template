# plan: 환경 변수 기반 Vercel 배포

- 목표: 배포 대상을 GitHub Environments 변수로 선택하고, 첫 대상으로 Vercel 지원
- 변경: `scripts/deploy.sh`(DEPLOY_TARGET 분기), `deploy.yml`/`rollback.yml`(env 전달, setup-node)
- 환경별 값(Environment 단위로 등록)
  - Variables: `DEPLOY_TARGET=vercel`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`, `VERCEL_CLI_VERSION`(정확한 semver, 예: `1.2.3`)
  - Secrets: `VERCEL_TOKEN`
- staging = Vercel preview, production = `--prod`
- 위험도: risk:high (.github/ 및 배포 스크립트 변경) - 사람 리뷰 필수
- 롤백: rollback 워크플로로 이전 SHA 재배포 (같은 스크립트 사용)

- 안전장치: production 에서 `DEPLOY_TARGET` 미설정이면 실패(fail-closed), environment 이름은 `staging|production` 만 허용
- 롤백: 40자리 전체 SHA 만 허용, 기본 브랜치 이력에 있는 커밋만, 기본 브랜치에서만 dispatch 가능

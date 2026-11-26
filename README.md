# AI-Native SDLC on GitHub

[AI 네이티브 SDLC 플레이북](https://claude.com/ko/resources/articles/the-ai-native-sdlc-playbook)을 GitHub Actions로 구현한 템플릿입니다.

## 단계 → GitHub 매핑

| 단계 | 아티팩트 | GitHub 구현 |
|---|---|---|
| Plan | `intent` | `.github/ISSUE_TEMPLATE/intent.yml` (+ CODEOWNERS 승인) |
| Design | `docs/specs/*.md` | spec PR, `docs/specs/` 는 CODEOWNERS 보호 |
| Build | `docs/plans/*.md` | `claude.yml` (`@claude` 멘션), `CLAUDE.md`, `.claude/settings.json` 훅 |
| Test | eval 스위트 | `ci.yml` (lint/test/build) + `evals` 잡 |
| Review/Deploy | PR 리뷰, 배포 | `claude-review.yml`, `deploy.yml` (production Environment 승인), `rollback.yml` |
| Maintain | intent 이슈 | `maintain.yml` (주간 스캔 → intent 이슈 → `@claude`) |

## 설정 순서
1. 레포 시크릿 `OPENROUTER_API_KEY` 등록 (OpenRouter 경유). Anthropic 직접 사용 시에는 두 워크플로의 `anthropic_api_key` 를 `secrets.ANTHROPIC_API_KEY` 로 바꾸고 `ANTHROPIC_BASE_URL` env 를 제거
2. `./scripts/setup-github.sh OWNER/REPO $(gh api users/<login> --jq .id)` 로 브랜치 보호, 환경 승인, 라벨 적용
3. `scripts/deploy.sh` 를 실제 배포 명령으로 교체
4. 이슈를 `Intent` 템플릿으로 만들고 `@claude` 로 시작

## 원칙
- 반드시 지켜야 하는 정책은 프롬프트가 아니라 **브랜치 보호 / Environments / 훅 / 권한 설정**으로 강제합니다.
- 에이전트는 production 게이트를 넘을 수 없습니다.
- 측정: intent→PR 시간, 1차 통과율, 리뷰 시간, 변경 실패율(DORA).

> `claude-code-action` 의 입력 옵션은 버전에 따라 달라질 수 있으니 [공식 문서](https://github.com/anthropics/claude-code-action)를 확인하세요.

## 배포 설정 (Vercel)
배포 대상은 환경 변수로 선택합니다. Settings → Environments 에서 `staging`, `production` 각각에 등록하세요.

| 종류 | 이름 | 설명 |
|---|---|---|
| Variable | `DEPLOY_TARGET` | `vercel` (미설정이면 로그만 출력하는 stub) |
| Variable | `VERCEL_ORG_ID` | Vercel 팀/계정 ID (`vercel link` 후 `.vercel/project.json`) |
| Variable | `VERCEL_PROJECT_ID` | Vercel 프로젝트 ID (같은 파일) |
| Variable | `VERCEL_CLI_VERSION` | 검증한 Vercel CLI 정확한 버전 (예: `npm view vercel version` 으로 확인). `latest` 금지 |
| Secret | `VERCEL_TOKEN` | Vercel 계정 토큰 |

- production 에서 `DEPLOY_TARGET` 이 비어 있으면 배포가 실패합니다 (fail-closed).
- staging 은 Vercel preview, production 은 `--prod` 배포입니다.
- 배포 대상을 늘리려면 `scripts/deploy.sh` 의 `case` 에 분기를 추가하세요.

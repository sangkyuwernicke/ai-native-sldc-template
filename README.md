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

# CLAUDE.md

이 레포는 AI 네이티브 SDLC 플레이북을 GitHub Actions로 구현한 템플릿이다.

## 검증 명령 (완료 전에 반드시 모두 통과)
- `make lint`
- `make test`
- `make build`
- `make evals`

## 워크플로 규칙
1. 구현 전에 `docs/plans/<이슈번호>-plan.md` 를 작성하고 승인을 받는다.
2. 요구사항은 `docs/specs/` 의 spec 을 따른다. spec 에 없는 동작은 추가하지 말고 질문한다.
3. 브랜치 `claude/<이슈번호>-<slug>` 에서 작업하고 PR 로만 반영한다. main 에 직접 push 하지 않는다.
4. 인증/결제/DB 마이그레이션/시크릿/`.github/` 변경은 PR 본문에 `risk:high` 로 명시한다.
5. 프로덕션 배포는 사람의 Environment 승인 후에만 진행된다. 우회하지 않는다.

## 학습 기록 (반복되는 실수는 여기에 추가)
- (비어 있음)

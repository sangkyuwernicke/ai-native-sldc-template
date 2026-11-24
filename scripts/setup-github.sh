#!/usr/bin/env bash
# 레포 보호 설정 적용: 브랜치 보호 + Environments(승인 게이트) + 라벨.
# 사용: ./scripts/setup-github.sh OWNER/REPO REVIEWER_USER_ID
#   REVIEWER_USER_ID: gh api users/<login> --jq .id
# 참고: private 레포의 브랜치 보호/환경 승인은 GitHub Pro 이상(또는 public 레포)에서 동작합니다.
set -euo pipefail
REPO="${1:?OWNER/REPO}"
REVIEWER_ID="${2:?reviewer user id}"

echo "== labels"
for l in "intent:0E8A16" "risk:high:B60205" "risk:low:0E8A16"; do
  name="${l%:*}"; color="${l##*:}"
  gh label create "$name" --color "$color" --repo "$REPO" --force
done

echo "== environments"
gh api -X PUT "repos/$REPO/environments/staging" >/dev/null
gh api -X PUT "repos/$REPO/environments/production" \
  --input - >/dev/null <<EOF
{"reviewers":[{"type":"User","id":$REVIEWER_ID}],"deployment_branch_policy":{"protected_branches":true,"custom_branch_policies":false}}
EOF

echo "== branch protection (main)"
gh api -X PUT "repos/$REPO/branches/main/protection" --input - >/dev/null <<'EOF'
{
  "required_status_checks": {"strict": true, "contexts": ["test", "evals"]},
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
echo "done"

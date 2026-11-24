#!/usr/bin/env python3
"""PreToolUse 훅: 보호 경로 수정을 결정론적으로 차단한다 (스킬/프롬프트는 권고일 뿐)."""
import json
import sys

PROTECTED = (".github/CODEOWNERS", "scripts/deploy.sh", ".claude/settings.json", ".claude/hooks/")

data = json.load(sys.stdin)
path = (data.get("tool_input") or {}).get("file_path", "")

if any(p in path for p in PROTECTED):
    print(f"보호된 경로 수정 차단: {path} (사람 승인 필요)", file=sys.stderr)
    sys.exit(2)  # exit 2 = 도구 호출 차단, stderr 가 에이전트에게 전달됨
sys.exit(0)

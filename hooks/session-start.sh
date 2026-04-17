#!/usr/bin/env bash
# chronista-style SessionStart hook
# Outputs JSON with additionalContext to inject project context into Claude's initial context.
# Fail-closed: on any error, emit empty context and exit 0 (never block the session).

set -uo pipefail

# Collect git context (silently fall back if not in a repo)
project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$project_dir" 2>/dev/null || true

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-")
last_commit=$(git log -1 --oneline 2>/dev/null || echo "-")
status_summary=$(git status --porcelain=v1 2>/dev/null | wc -l | tr -d ' ')
project_name=$(basename "$project_dir" 2>/dev/null || echo "-")

# Build the additionalContext payload as plain markdown
context=$(cat <<EOF
## Chronista Session Context

- Project: \`${project_name}\`
- Branch: \`${branch}\`
- Last commit: ${last_commit}
- Uncommitted files: ${status_summary}

### 最優先アクション

**creo-memories から過去の記憶を検索せよ**。以下を順に試し、関連する記憶があれば要約してユーザーに提示すること:

1. \`mcp__creo-memories__search\` query=\`"${project_name}"\` limit=5
2. \`mcp__creo-memories__search\` query=\`"${branch}"\` limit=3（ブランチ名から Linear Issue を推測）
3. \`mcp__creo-memories__list_recent_memories\` limit=5（直近の活動確認）

記憶が見つかった場合、1-2行で要約して「関連記憶を検索しました」と報告する。

### Chronista Style の原則

- **ヒアリングファースト** — 実装前に質問でコンテキスト収集
- **一問一答** — 複数質問を一度に投げない
- **セカンドオピニオン** — Gemini等で第二意見
- **Simplicity & Straightforward** — data/calculations/actions の分類、直線的な経路

詳細は \`chronista-style\` スキル参照。
EOF
)

# Escape for JSON: use python to handle quoting safely
escaped=$(printf '%s' "$context" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null)

# Fallback if python3 unavailable
if [ -z "$escaped" ]; then
  # Minimal escape (newlines and double quotes)
  escaped=$(printf '%s' "$context" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | awk '{printf "%s\\n", $0}')
  escaped="\"${escaped%\\n}\""
fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ${escaped}
  }
}
EOF

exit 0

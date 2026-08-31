#!/usr/bin/env bash
# chronista-style SessionStart hook
# Outputs JSON with additionalContext to inject project context into Claude's initial context.
# Fail-closed: on any error, emit empty context and exit 0 (never block the session).

set -uo pipefail

project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$project_dir" 2>/dev/null || true

# --- Git context ---
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-")
last_commit=$(git log -1 --oneline 2>/dev/null || echo "-")
status_summary=$(git status --porcelain=v1 2>/dev/null | wc -l | tr -d ' ')
project_name=$(basename "$project_dir" 2>/dev/null || echo "-")

# --- Atlas candidate detection (convention + git remote hybrid) ---
# Candidate 1: directory basename (as-is)
atlas_candidate_dir="$project_name"

# Candidate 2: directory basename with common prefix stripped
# (e.g., "claude-plugin-chronista-style" → "chronista-style")
atlas_candidate_stripped=$(printf '%s' "$project_name" | sed -E 's/^(claude-plugin-|skillset-?|plugin-)//')
if [ "$atlas_candidate_stripped" = "$atlas_candidate_dir" ]; then
  atlas_candidate_stripped=""
fi

# Candidate 3: git remote URL → repo name
remote_url=$(git config --get remote.origin.url 2>/dev/null || echo "")
atlas_candidate_remote=""
if [ -n "$remote_url" ]; then
  # Handle both https://github.com/org/repo(.git) and git@github.com:org/repo(.git)
  # BSD sed compatible: strip .git first, then take last path segment
  atlas_candidate_remote=$(printf '%s' "$remote_url" 2>/dev/null \
    | sed -E 's#\.git$##' 2>/dev/null \
    | awk -F'[:/]' '{print $NF}' 2>/dev/null \
    | sed -E 's/^(claude-plugin-|skillset-?|plugin-)//' 2>/dev/null)
  if [ "$atlas_candidate_remote" = "$atlas_candidate_dir" ] || [ "$atlas_candidate_remote" = "$atlas_candidate_stripped" ]; then
    atlas_candidate_remote=""
  fi
fi

# Build candidate lists — primary (directory) takes precedence over fallback (remote)
primary_candidates="$atlas_candidate_dir"
[ -n "$atlas_candidate_stripped" ] && primary_candidates="$primary_candidates / $atlas_candidate_stripped"
fallback_candidates="$atlas_candidate_remote"

# --- Build additionalContext ---
context=$(cat <<EOF
## Chronista Session Context

- Project dir: \`${project_name}\`
- Branch: \`${branch}\`
- Last commit: ${last_commit}
- Uncommitted files: ${status_summary}
- Remote: \`${remote_url:-none}\`

### Atlas 候補（creo-memories）

**優先候補（ディレクトリ名ベース・A）**: \`${primary_candidates}\`
**フォールバック候補（git remote・C）**: \`${fallback_candidates:-なし}\`

**最初にやること（この順で試せ）:**

1. \`mcp__creo-memories__list_atlas\` を呼んで全 Atlas を列挙
2. **優先候補 A** に exact match があればそれを採用、フォールバックは見ない
3. A に match が無ければ、**フォールバック候補 C** で exact match を探す
4. 両方 match しなければ、\`AskUserQuestion\` で「どの Atlas を使うか？ 新規作成するか？」を尋ねる
5. 確定した Atlas 名を以降の \`search\` / \`remember\` / \`create_todo\` の scope に指定する

### 記憶の検索（Atlas 確定後）

1. \`mcp__creo-memories__search\` query=\`"${atlas_candidate_dir}"\` limit=5
2. \`mcp__creo-memories__search\` query=\`"${branch}"\` limit=3（ブランチ名から関連 memory を推測）
3. \`mcp__creo-memories__list_recent_memories\` limit=5（直近の活動）

関連記憶が見つかった場合、1-2 行で要約して「関連記憶を検索しました」と報告する。

### Chronista Style の原則

- **ヒアリングファースト** — 実装前に質問でコンテキスト収集
- **一問一答** — 複数質問を一度に投げない
- **セカンドオピニオン** — Gemini 等で第二意見
- **Simplicity & Straightforward** — data/calculations/actions の分類、直線的な経路

詳細は \`chronista-style\` スキル参照。
EOF
)

# --- Escape for JSON ---
escaped=$(printf '%s' "$context" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null)

if [ -z "$escaped" ]; then
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

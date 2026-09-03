#!/usr/bin/env bash
# fabrication-tripwire.sh — Stop hook. 2026-07-04
# Minimal gate against reporting tool results that were never produced. FAIL-OPEN:
# every abnormal path exits 0 (allow) — the gate must never take a session down.
# Escape hatch: literal token  TRIPWIRE-ACK  on a line BY ITSELF = conscious override.
# (An inline mention of the token in explanatory prose does NOT disarm the gate.)
#
# Design notes (verified against real transcripts, 2026-07-04):
# - Turn boundary = last REAL user prompt. Real prompts carry .message.content as a
#   plain STRING; array content with a text block (prompt with attachments) also
#   counts. tool_result-bearing entries never do. Stop-hook feedback is injected as
#   a string user entry with a "Stop hook feedback:" prefix — it is NOT a boundary:
#   treating it as one would orphan the turn's earlier tool_results and false-block
#   the post-block rewrite.
# - Prose scanned = the FINAL assistant message of the turn only (the report the
#   user reads), so a stale boundary cannot drag old messages into the scan.
# - Backing = tool_result content from the WHOLE transcript (session), not just this
#   turn. Rationale (2026-09-03): Fable 5.1 harness asks for a stand-alone recap at the
#   end of a turn, which legitimately re-quotes results observed in EARLIER turns.
#   Same-turn backing false-blocked those recaps. Session-wide backing still stops the
#   real failure — reporting output that was never produced anywhere.
set -uo pipefail

allow(){ exit 0; }
block(){ jq -n --arg r "$1" '{decision:"block",reason:$r}'; exit 0; }

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat 2>/dev/null)" || exit 0
T="$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)"
[ -n "$T" ] && [ -f "$T" ] || exit 0

tags="$(jq -rc 'try (
  if .type=="user" and (
       ( (.message.content | type) == "string"
         and ((.message.content | startswith("Stop hook feedback:")) | not) )
       or ( (.message.content | type) == "array"
            and any(.message.content[]?; .type=="text")
            and (any(.message.content[]?; .type=="tool_result") | not) )
     ) then "B" else "." end
) catch "."' "$T" 2>/dev/null)"
[ -n "$tags" ] || exit 0
line="$(printf '%s\n' "$tags" | grep -n '^B$' | tail -1 | cut -d: -f1)"
[ -n "$line" ] || line=0

turn="$(tail -n +"$((line+1))" "$T" 2>/dev/null)"
[ -n "$turn" ] || exit 0

prose="$(printf '%s' "$turn" | jq -rs '[
  .[] | select(.type=="assistant")
      | [.message.content[]? | select(.type=="text") | .text]
      | select(length>0) | join("\n")
] | last // empty' 2>/dev/null)"
[ -n "$prose" ] || exit 0

# Conscious override: token on a line by itself (inline mentions do not count).
printf '%s\n' "$prose" | grep -qxF 'TRIPWIRE-ACK' && exit 0

tools="$(jq -r 'select(.type=="user") | .message.content[]? | select(.type=="tool_result") | (.content | if type=="string" then . elif type=="array" then (map(.text? // "")|join("\n")) else tostring end)' "$T" 2>/dev/null)"

patterns=(
  'test result:'
  '[0-9]+ passed[;,]'
  'all checks were successful'
  'Squashed and merged'
  'To github\.com'
  '[0-9a-f]{7,12}\.\.[0-9a-f]{7,12}'
  'File created successfully at'
  'has been updated successfully'
  'HEAD is now at'
  '-> (origin/|FETCH_HEAD)'
)
viol=""
for p in "${patterns[@]}"; do
  printf '%s' "$prose" | grep -Eq -e "$p" || continue
  printf '%s' "$tools" | grep -Eq -e "$p" && continue
  m="$(printf '%s' "$prose" | grep -Eo -e "$p" | head -1)"
  viol="${viol}  - \"${m}\"  [${p}]
"
done
[ -z "$viol" ] && allow
block "FABRICATION TRIPWIRE — this turn's final message contains tool-output-shaped text with NO matching tool_result anywhere in this session:
${viol}
Resolve by ONE of: (1) run the real tool and quote its ACTUAL output; (2) delete the unbacked text; (3) if you are deliberately quoting past / example output, add the token TRIPWIRE-ACK on a line by itself. Never report a result you did not observe."

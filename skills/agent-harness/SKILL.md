---
name: agent-harness
description: AI agent の action space・tool 定義・observation format を設計し、completion rate を上げる。 agent harness を構築・最適化するときの語彙と判断軸を提供する。
version: 1.0.0
origin: ECC (Everything Claude Code) — chronista 適合 fork
tags: [agent-design, harness, action-space, observation, tool-design]
---

# Agent Harness 🦾

> **「agent の output 品質は、agent そのものより harness で決まる。」**

**Core principle:** agent が何を達成するかは、与えた **action space / observation / recovery / context budget** の 4 軸で 8 割決まる。 agent を改善するなら、まず harness を改善せよ。

## いつ使うか

- AI agent (Claude Code subagent / VP Stand actor / 自作 LLM agent) の completion rate が低い
- agent が同じ tool を繰り返し叩く / drift する / 諦める
- 新しい agent を設計する (例: VP の Stand Actor Framework、 ccwire mesh の worker)
- 既存 agent の cost-per-task が高い

VP-D11 の **StandActor trait 階層 (Renderable / Headless / Pty)** や、**VP worker lane の autonomous mode** を設計するときの判断軸として使う。

## いつ使わないか

| ❌ agent-harness を使うな | ✅ 代わりに |
|---|---|
| agent failure を debug したい | `agent-introspection` |
| 設計判断の合議 | `council` |
| agent output の検証 | `santa-method` |
| 単に prompt を書きたい | prompt を直接書く |

## Core Model — agent 品質の 4 軸

agent output の上限は次の 4 軸の **積** で決まる:

```
output_quality = action_space × observation × recovery × context_budget
```

どれか 1 軸でも壊れていると、他軸を上げても掛け算で頭打ちになる。

### 1. Action Space Quality

agent が呼べる **tool / cmd の集合** の質。

#### 設計原則

- **stable, explicit な tool 名** — 動詞主体 (`create_pane`, `send_message`)、 sema 揺れない
- **schema-first で narrow な input** — Optional 多用は迷う、必須/任意を明示
- **deterministic な output 形** — 同じ input は同じ shape を返す
- **catch-all tool は最終手段** — `do_anything` は agent を迷わせる

#### Granularity rule

| 粒度 | 用途 | 例 |
|---|---|---|
| **micro-tool** | 高 risk operation | `deploy`, `migration`, `permission_change` |
| **medium tool** | 一般的 edit/read/search | `read_file`, `search_code`, `edit_block` |
| **macro tool** | round-trip cost が支配的なとき | `batch_process`, `pipeline_run` |

VP の Stand actor で言うと:
- `Pty` capability = micro (PTY 起動は high-risk)
- `Renderable.render()` = medium (普通の event handle)
- composite `dispatch_event()` macro は避ける (個別 tool で十分)

### 2. Observation Quality

tool response が agent に**何を伝えるか**。

すべての tool response に含めるべき field:

| field | 役割 |
|---|---|
| `status` | `success` / `warning` / `error` |
| `summary` | 1 行 result (人間も読みやすい) |
| `next_actions` | 次に取れる行動 (agent の planning input) |
| `artifacts` | file path / ID リスト (副作用の可視化) |

#### Observation の悪例 vs 良例

```text
❌ 悪い: "OK"
❌ 悪い: "Error"
❌ 悪い: 1000 行の raw log dump

✅ 良い:
{
  "status": "warning",
  "summary": "Lane created but TopicRouter binding pending",
  "next_actions": ["call lane.bind_topic()", "verify with /api/lanes"],
  "artifacts": ["lane-abc123"]
}
```

### 3. Recovery Quality

error path で agent が**自力で立ち直れる**かどうか。

すべての error response に必須:

- **root cause hint** — 何が失敗したか (retry で解決するか、別 path が必要か)
- **safe retry instruction** — backoff 推奨、idempotency 保証の有無
- **explicit stop condition** — どこまで retry したら諦めるか

#### Recovery の悪例 vs 良例

```text
❌ 悪い: { "error": "failed" }
❌ 悪い: { "error": "Internal Server Error" }

✅ 良い:
{
  "status": "error",
  "error_kind": "transient_network",
  "summary": "TheWorld /api/lanes timed out",
  "root_cause": "SP at port 33002 likely starting up",
  "retry": {
    "safe": true,
    "backoff_ms": 2000,
    "max_attempts": 3
  },
  "stop_if": "After 3 retries, call vp world status"
}
```

### 4. Context Budget Quality

agent の **context window** をどう使うか。

#### 設計 rule

- **system prompt は最小・不変** — 大きい guidance は skill に追い出す
- **長 document は inline せず file 参照** — `Read("path")` で必要時だけ
- **phase boundary で compact** — 任意 token threshold ではなく、論理境界で
- **skill は on-demand load** — `Skill` tool で必要時起動、常時 system prompt に積まない

VP の context budget 設計例:
- ECC plugin 全体 enable は ~150 skill が常時 context → disable で軽減
- creo-memories memory は **search → get_memory** で必要時のみ取得
- ccwire mesh は session 別 context、共有は **memory + msgbox** で

## Architecture pattern guidance

| pattern | 強み | best for |
|---|---|---|
| **ReAct** | 探索的、 plan → act → observe | uncertain path、 探索的 task |
| **Function-calling** | structured deterministic | 決まった flow の実行 |
| **Hybrid (推奨)** | ReAct planning + typed tool exec | 大半の現実 task |

VP の Stand Ensemble は **Hybrid 型**: HD (Claude CLI) は ReAct、 PP/GE/HP は Event-driven (function-call 寄り)。

## Benchmarking

agent harness を変えたら、必ず metric を track:

| metric | 解釈 |
|---|---|
| **completion rate** | task を最後まで完了した % |
| **retries per task** | tool 呼び出しの retry 回数 (低いほど observation が good) |
| **pass@1, pass@3** | 1 回目 / 3 回 試行で pass する % |
| **cost per successful task** | 成功 task 当たりの token cost |

## creo-memories 連携

agent harness の改善は **再利用可能な学び**になりやすい。memory に積極的に pin:

| 状況 | 記録方法 |
|---|---|
| harness 設計判断 (action space 粒度等) | category: `design-decision`, tag: `[agent-harness, harness-design]` |
| benchmark 結果の比較 | category: `learning`, tag: `[harness-eval, before-after]` |
| anti-pattern 発見 | category: `learning`, tag: `[harness-trap]` |

VP の Stand Actor Framework のような **長期育成する harness** では、memory に history 残すと進化が tractable になる。

## chronista 文脈での適用例

### 例 1: VP-D11 StandActor trait 階層の設計

D11-A で `StandActor` 基底 + `Renderable / Headless / Pty` trait を設計するとき:

- **Action space**: 各 trait が提供する method (handle / render / build_pty)
- **Observation**: Event payload (CreoContent envelope) で構造化
- **Recovery**: Stand failure 時の causation tree 経由 introspection
- **Context budget**: live_memory / snapshot_memory で per-pane scope に分離

→ agent-harness の 4 軸を design 議論の checklist として使う。

### 例 2: worker lane の autonomous mode

Worker が autonomous で走るとき:

- **Action space**: `wire_send` (Q&A) / `wire_receive` / 直接 tool 群
- **Observation**: 自分の tool result + lead からの reply
- **Recovery**: 判断迷ったら `wire_send` で lead に聞く ("safety valve")
- **Context budget**: lead が渡す指示 + worker local 作業 context

→ relay モード vs autonomous モードの **harness 差** をこの 4 軸で記述すると整理しやすい。

### 例 3: Subagent 起動時の prompt 設計

`Agent` tool で subagent を起動するとき (例: `council` の Skeptic / Pragmatist / Critic):

- **Action space**: subagent_type で絞る (general-purpose vs Explore)
- **Observation**: 短く構造化された return format を強制
- **Recovery**: subagent が立ち往生したら return で escalate signal
- **Context budget**: parent の history を渡さない (anti-anchoring)

## NG パターン

| ❌ 悪い | ✅ 良い |
|---|---|
| 同 sema を持つ tool が多数並ぶ | 統合 or rename |
| tool response が prose だけ | 構造化 (status / summary / next_actions / artifacts) |
| error が `{error: "failed"}` | root_cause + retry + stop_if |
| system prompt に 5000 行の guideline | skill に分離して on-demand |
| 全 conversation を subagent に渡す | compact context のみ (anti-anchoring) |

## 他スキルとの住み分け

| スキル | 役割 | agent-harness との関係 |
|---|---|---|
| `agent-introspection` | failure の self-debug | 補完: harness で予防、 introspection で検出 |
| `council` | 設計判断 | harness 設計の judgement に council を nest 可 |
| `santa-method` | output 検証 | output 品質 check、 harness 改善の input |
| `spec-design-guide` | 設計記録 | harness 設計を ADR / docs/design に永続化 |
| `code-review` | コード品質 | harness 実装後の品質確認 |

## 発火の目安

- 新規 agent / Stand / worker を設計するとき
- 既存 agent の completion rate / pass@k が悪化
- 同じ failure mode が繰り返し発生
- benchmark で cost per task が上がっている
- VP のような **長期育成する harness** の major version up

## アンチパターン

### Anti-pattern: Tool 過多
- **症状**: 似た sema を持つ tool が 10 個以上
- **問題**: agent が選択に迷う、systematic error 増
- **対策**: 統合・rename、 micro/medium/macro 階層で整理

### Anti-pattern: Opaque observation
- **症状**: tool が `"OK"` `"failed"` のような不透明 string を返す
- **問題**: agent が次 action を決められない
- **対策**: status / summary / next_actions / artifacts 必須化

### Anti-pattern: Error-only output
- **症状**: error message だけで recovery hint なし
- **問題**: agent が retry storm に陥る
- **対策**: root_cause + retry policy + stop_if 必須

### Anti-pattern: Context overload
- **症状**: 関係ない reference を context に積む
- **問題**: signal/noise が下がり quality 低下
- **対策**: phase boundary で compact、 skill on-demand

## クイックリファレンス

| 軸 | 確認 question |
|---|---|
| Action Space | tool 名は安定? schema は narrow? output は deterministic? |
| Observation | status / summary / next_actions / artifacts 揃ってる? |
| Recovery | root_cause / retry / stop_if 揃ってる? |
| Context Budget | system prompt 不変? skill on-demand? phase で compact? |

## 参考

- 元 skill: ECC `agent-harness-construction` (Everything Claude Code)
- 関連 design: VP の Stand × Pane × Lane (mem `D11 Pane Revival`)
- 姉妹スキル: `agent-introspection`, `council`, `santa-method`

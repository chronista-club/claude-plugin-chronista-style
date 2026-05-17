---
name: agent-introspection
description: AI agent 自身の failure (loop / drift / max tool call / 環境ズレ) に対する構造化 self-debug。 capture → diagnose → contained recovery → introspection report の 4 phase で、 retry blind を防ぎ human escalation の前に agent が自己修正する。
version: 1.0.0
origin: ECC (Everything Claude Code) — chronista 適合 fork
tags: [agent-failure, self-debug, introspection, recovery, ai-debugging]
---

# Agent Introspection 🔍

> **「同じ tool を 3 回叩く前に、世界の状態を確認せよ。」**

**Core principle:** agent が repeated failure に遭遇したとき、 blind retry は **token を消費するだけで前進しない**。 失敗を **capture → diagnose → contained recovery** の構造で扱い、推測ではなく**観察**で動く。

## The Iron Rule

```
3 回失敗したら、 retry を止めて diagnose せよ
```

「もう 1 回試せば動くかも」は agent failure の anti-pattern 1 番。

## いつ使うか

AI agent (Claude Code session / VP Stand actor / VP worker lane / 自作 LLM agent) が次のような**症状**を見せたとき:

- **Max tool call / loop limit** で停止
- 同じ tool / cmd を **繰り返し呼ぶ**のに前進しない
- context 肥大で reasoning quality が劣化 (drift)
- file system / 環境状態と **expectation の mismatch**
- tool failure が連続するが diagnosis 次第で recoverable に見える

## いつ使わないか

| ❌ agent-introspection を使うな | ✅ 代わりに |
|---|---|
| **コード/システムのバグ調査** (test failure / production bug) | `systematic-debugging` |
| 完了前 deterministic 検証 (build/lint/test) | `verification` |
| code 変更後の機能検証 | `verification` |
| 設計判断の合議 | `council` |
| output の品質検証 | `santa-method` |
| 完全に runtime 制御不可な領域 (harness 自体の bug) | human escalation |

## Scope Boundary

**activate 対象**:
- 失敗 state の正確な capture
- 既知 failure pattern への match
- contained recovery action の適用
- 構造化された debug report 出力

**activate しない**:
- 機能検証 (`verification` の領域)
- 言語/framework 特化 debug (それぞれの skill が存在するならそちらを優先)
- harness 自体が enforce できない runtime promise

## 4 フェーズ

```
Capture → Diagnose → Contain → Report
```

番号でなく**名前で参照**する。

### 📸 Capture（失敗 state の記録）

retry 前に**正確に**失敗を記録する。 blind retry より先に必ず capture。

#### 記録項目

- error type / message / stack trace (取得可能なら)
- 直近の意味のある tool call 列
- agent が達成しようとしていた goal
- **context pressure**: prompt 重複、 oversize log paste、 plan 重複、 暴走 note
- **environment 前提**: cwd、 branch、 service state、 期待 file 群

#### 最小 capture テンプレート

```markdown
## Failure Capture
- Session / task:
- Goal in progress:
- Error:
- Last successful step:
- Last failed tool / command:
- Repeated pattern seen:
- Environment assumptions to verify:
```

### 🔬 Diagnose（root cause の識別）

**何かを変える前**に、 failure を既知 pattern に match する。

#### Pattern table (基本)

| Pattern | 推定 root cause | check |
|---|---|---|
| Max tool calls / 同 cmd 反復 | loop / 出口がない observer path | 直近 N 個の tool call を inspect |
| Context overflow / reasoning 劣化 | 無制限 note、 plan 重複、 oversize log | recent context の冗長性を確認 |
| `ECONNREFUSED` / timeout | service 不在 or 不正 port | service health / URL / port を確認 |
| `429` / quota | retry storm or backoff 欠落 | call 頻度と spacing 確認 |
| 書き込み後 file 不在 / stale diff | race / 不正 cwd / branch drift | path / cwd / git status / 実 file 確認 |
| 修正後も test 失敗 | 仮説が wrong | 失敗 test 1 つに絞り bug 再導出 |

#### Diagnosis 質問

- **type 判定**: logic failure / state failure / environment failure / policy failure のどれ?
- **drift 判定**: agent は real objective を見失って sub-task を最適化していないか?
- **reproducibility**: deterministic か transient か?
- **smallest reversible action**: diagnosis を validate する**最小 action** は?

### 🔧 Contain（最小 action での recovery）

**diagnosis surface を変える最小 action**を取る。 recovery 自体が cascade を引き起こさないように。

#### 安全 recovery action

- 反復 retry を止め、仮説を **restate**
- 低 signal context を trim、 active goal + blocker + evidence のみ残す
- 実 file system / branch / process state を **再観測**
- task scope を **1 失敗 cmd / 1 file / 1 test** に絞る
- speculative reasoning から **direct observation** に切替
- 高 risk / 外部 blocker なら **human escalate**

> **重要**: 「reset agent state」「update harness config」のような **harness が実際 enforce できない action** を約束するな。 actual tool で実行できるものだけを claim せよ。

#### Contained recovery checklist

```markdown
## Recovery Action
- Diagnosis chosen:
- Smallest action taken:
- Why this is safe:
- What evidence would prove the fix worked:
```

### 📋 Report（introspection report）

次の agent / human が読んで動ける形で**報告**する。 「I fixed it」だけは不十分。

```markdown
## Agent Self-Debug Report
- Session / task:
- Failure:
- Root cause:
- Recovery action:
- Result: success | partial | blocked
- Token / time burn risk:
- Follow-up needed:
- Preventive change to encode later:
```

## Recovery Heuristics（優先順）

1. **real objective を 1 sentence で restate** する
2. memory ではなく **world state を verify** する
3. failing scope を **shrink** する
4. 1 つの **discriminating check** を実行する
5. それから retry する

| ❌ 悪い pattern | ✅ 良い pattern |
|---|---|
| 同 action を 3 回 wording だけ変えて retry | capture → classify → 1 direct check → check の結果で plan 変更 |
| 失敗を黙って context に積む | capture を Report で永続化 |
| diagnose なしで retry storm | MAX 3 で escalate |

## creo-memories 連携

agent failure pattern は **再利用可能な instinct** になりやすい。 memory に積極的に記録:

| 状況 | 記録方法 |
|---|---|
| 新しい failure pattern | category: `learning`, tag: `[agent-failure, pattern-name]` |
| 既知 pattern の再発 | 既存 memory に `extends` で reply / annotation |
| harness 改善のトリガー | category: `design-decision`, tag: `[harness-evolution, agent-introspection]` |
| 緊急 escalation | category: `incident`, tag: `[urgent, agent-stuck]` |

**学びの形**:
- 「context overflow 検出 → trim → recover」が 3 回起きたら、**自動 trim hook** を harness に追加検討
- 「同 cmd 反復」が頻発する agent → **action space 整理** (`agent-harness` 参照)

## chronista 文脈での適用例

### 例 1: worker autonomous mode の drift

Worker が autonomous で走っていて、同じ tool を反復し始めた:

1. **Capture**: 直近 10 tool call を log、 goal restate、 wire_send で lead に状態通知
2. **Diagnose**: pattern table から「Max tool calls / 同 cmd 反復」 → loop or 出口なし
3. **Contain**: tool reps を止め、`wire_send` で lead に「迷ってる、 confirmation 欲しい」 (autonomous の safety valve)
4. **Report**: 何が trigger だったか、 next session で予防可能か

### 例 2: Stand actor の event loop drift

VP の PP Stand actor が event を処理せず idle 化:

1. **Capture**: causation tree で last successful event → idle までの timeline、 inbox の queue 長
2. **Diagnose**: subscribe topic mismatch? Mailbox 失効?
3. **Contain**: actor を re-register、 missed event は tail で再 inject
4. **Report**: failure pattern を memory pin、 D11-G (HP Headless) の参考に

### 例 3: Long session での context overflow

session が長くなり、 reasoning quality が落ちた感覚があるとき:

1. **Capture**: 現 context size 推定 (skill list / history / MCP server で何 token 食ってるか)
2. **Diagnose**: pattern table から「Context overflow / reasoning 劣化」
3. **Contain**: 不要 plugin disable で skill list 軽減、 strategic compact 提案
4. **Report**: memory pin (plugin disable 判断を memory 化)

## NG パターン

| ❌ 悪い | ✅ 良い |
|---|---|
| 失敗してすぐ blind retry | capture → diagnose → contain |
| diagnose なしで「reset agent state」claim | actual tool で実行できる action のみ |
| Report skip して「I fixed it」 | 必ず failure pattern + root cause + recovery + evidence |
| 同 reviewer / agent で fix loop | escalate to human (or fresh agent) |
| failure pattern を memory に残さない | learning category で pin、 instinct 化 |
| systematic-debugging と混同 | コードバグは systematic-debugging、 agent failure は agent-introspection |

## 他スキルとの住み分け

| スキル | 役割 | agent-introspection との関係 |
|---|---|---|
| `systematic-debugging` | コード/システムバグの根本原因調査 | **領域が異なる**: agent-introspection = agent 自身の failure、 systematic-debugging = code/system のバグ |
| `agent-harness` | harness 設計 | 補完: harness で予防、 introspection で検出 |
| `verification` | 完了前 deterministic checks | verification は build/test、 introspection は agent 内部 |
| `council` | 設計判断 | introspection の result を council にかける流れもある |
| `santa-method` | output 検証 | santa は output、 introspection は agent process 自身 |
| `route` | path 選択 | route で plot した path が走らなかったとき introspection |

## 発火の目安

- agent / subagent が **repeated failure**
- 「もう 1 回 retry してみよう」を **2 回以上**思った
- token 消費が前進と釣り合わない
- agent が drift して original goal を見失っている感覚
- VP worker lane / VP Stand actor の loop / idle / stuck

逆に発火しないケース:
- 1 回限りの transient error (retry で resolve、 pattern なし)
- コード/build/test failure (`systematic-debugging` 領域)
- 設計判断の迷い (`council` 領域)

## アンチパターン

### Anti-pattern: Blind retry storm
- **症状**: 同 cmd を wording 変えて 3 回以上呼ぶ
- **問題**: token 消費だけ、 diagnosis surface 変化なし
- **対策**: MAX 3 で停止、 capture → diagnose

### Anti-pattern: Phantom recovery action
- **症状**: 「agent state を reset した」「config を update した」と claim、 実 tool 不在
- **問題**: agent が嘘をつき、 後続が信用できない
- **対策**: actual tool で実行できる action のみ claim

### Anti-pattern: Capture skip
- **症状**: 失敗してすぐ recovery 開始
- **問題**: root cause 不明のまま、 same failure 再発
- **対策**: Capture template を埋めてから次に進む

### Anti-pattern: Report 省略
- **症状**: 「I fixed it」だけで session を進める
- **問題**: 同 failure が次回再発、 instinct 化しない
- **対策**: Report template + memory pin

## クイックリファレンス

| Phase | 主な活動 | 完了条件 |
|---|---|---|
| **Capture** | 失敗 state を template に埋める | what / where / why が記述された |
| **Diagnose** | pattern table と match | root cause hypothesis 確立 |
| **Contain** | 最小 action で recovery | evidence で fix 確認 or escalate |
| **Report** | self-debug report 出力 | next agent / human が読んで動ける |

## 参考

- 元 skill: ECC `agent-introspection-debugging` (Everything Claude Code)
- 関連 skill: `systematic-debugging` (コード/システムバグ用、 領域が異なる)
- 姉妹スキル: `agent-harness`, `council`, `santa-method`, `verification`

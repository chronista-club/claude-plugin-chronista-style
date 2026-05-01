---
name: santa-method
description: 多 agent 敵対的検証 (adversarial verification) と収束 loop。**独立した 2 reviewer が両方 PASS** するまで output を出荷しない。生成 agent 自身の盲点を、文脈共有しない 2 人目で破る。
version: 1.0.0
origin: Ronald Skelton (RapportScore.ai) — chronista 適合 fork (via ECC)
tags: [verification, adversarial, dual-review, convergence, quality-gate]
---

# Santa Method 🎅

> **「リストを作り、二度確認する。Naughty なら Nice になるまで直す。」**

**Core principle:** 単一 agent が自身の output を review しても、**生成時と同じ bias** で見るので盲点は埋まらない。**文脈を共有しない 2 reviewer** が両方 PASS して初めて出荷。

## The Iron Rule

```
1 reviewer の OK は、出荷判断の根拠にならない
```

reviewer A の OK + reviewer B の OK = 出荷。それ以外は naughty。例外は作らない。

## いつ使うか

output が **published / deployed / consumed by end users** されるとき:

- 規制・compliance・brand 制約が効く成果物
- production に human review なしで ship される code
- 技術文書・教育コンテンツ・customer-facing コピーの精度
- batch 生成 (100 件以上) で spot-check では systematic pattern を見落とす場面
- hallucination リスクが高い (claims / 数値 / API reference / legal language)

## いつ使わないか

| ❌ santa-method を使うな | ✅ 代わりに |
|---|---|
| 内部 draft / 探索的 research | 通常の review |
| build / lint / test で検証可能 | `verification` (deterministic checks) |
| 意思決定の合議 | `council` (decision 系) |
| 単独レビュアーのコードレビュー | `code-review` |
| バグ調査 | `systematic-debugging` |

## 4 フェーズ

```
Generate → Dual Review → Verdict Gate → Fix Until Nice
```

番号でなく**名前で参照**する。

```
┌─────────────┐
│  GENERATOR   │  Phase: Generate
│  (Agent A)   │  通常通り output を生成
└──────┬───────┘
       │ output
       ▼
┌──────────────────────────────┐
│   DUAL INDEPENDENT REVIEW     │  Phase: Dual Review
│  ┌───────────┐ ┌───────────┐  │  2 agent 並列、同 rubric、
│  │ Reviewer B │ │ Reviewer C │  │  互いの review を見ない
│  └─────┬─────┘ └─────┬─────┘  │
└────────┼──────────────┼────────┘
         ▼              ▼
┌──────────────────────────────┐
│        VERDICT GATE           │  Phase: Verdict Gate
│  B PASS AND C PASS → NICE     │  両方必須、部分点なし
│  Otherwise → NAUGHTY           │
└──────┬──────────────┬─────────┘
    NICE           NAUGHTY
       │              │
       ▼              ▼
   [ SHIP ]    ┌─────────────┐
               │  FIX CYCLE   │  Phase: Fix Until Nice
               │ iter++       │
               │ MAX 3 iter   │
               │ then escalate│
               └──────────────┘
```

### 🎁 Generate（生成）

通常の生成 workflow を変えない。santa-method は **post-generation 検証 layer**であり、生成戦略ではない。

### 👀 Dual Review（独立 2 reviewer）

`Agent` tool で **subagent を 2 個並列起動**。critical invariant:

1. **Context isolation** — どちらの reviewer も他方の評価を見ない
2. **同 rubric** — 評価基準は完全に同一
3. **同 input** — 元 spec + 生成 output、両方 reviewer に渡す
4. **構造化出力** — prose ではなく typed verdict

#### Reviewer prompt template

```text
You are an independent quality reviewer. You have NOT seen any other review of this output.

## Task Specification
{task_spec}

## Output Under Review
{output}

## Evaluation Rubric
{rubric}

## Instructions
Evaluate the output against EACH rubric criterion. For each:
- PASS: criterion fully met, no issues
- FAIL: specific issue found (cite the exact problem)

Return your assessment as structured JSON:
{
  "verdict": "PASS" | "FAIL",
  "checks": [
    {"criterion": "...", "result": "PASS|FAIL", "detail": "..."}
  ],
  "critical_issues": ["..."],
  "suggestions": ["..."]
}

Be rigorous. Your job is to find problems, not to approve.
```

#### Rubric 設計 (最重要 input)

vague rubric は vague review しか出さない。**全 criterion に objective pass/fail 条件**を持たせる。

| Criterion | Pass Condition | Failure Signal |
|---|---|---|
| 事実精度 | 全 claim が出典で検証可能 | 捏造数値、存在しない version、存在しない API |
| Hallucination-free | 捏造 entity/quote/URL/reference なし | 存在しないリンク、出典のない quote |
| 完全性 | spec の全要件をカバー | section 抜け、edge case 欠落 |
| Compliance | project 制約を pass | 禁止用語、tone 違反、規制違反 |
| 内部一貫性 | output 内で矛盾なし | section A と section B が食い違う |
| 技術的正しさ | code がコンパイル/動作、algorithm 健全 | syntax error、logic bug、複雑度誤認 |

#### 領域特化 rubric 拡張

**コンテンツ/マーケ**: brand voice / SEO / 商標誤用 / CTA

**コード**: type safety / error handling / security (secret 露出、injection) / 新 path のテストカバレッジ

**規制対応 (regulated/legal/financial)**: 結果保証なし / 必須 disclaimer / 認可用語 / 司法管轄言語

### 🎯 Verdict Gate（NICE or NAUGHTY）

```
両者 verdict == "PASS" → NICE (ship)
それ以外 → NAUGHTY (issue 集約 → fix → 再 review)
```

**両方 PASS 必須の理由**: 1 reviewer だけが捕捉した issue は **real な issue**。もう一方の盲点こそ santa-method が排除すべき failure mode。

### 🔧 Fix Until Nice（収束 loop）

- MAX 3 iteration
- 各 round で **fresh agent** (前 round の memory を持たない)
- fix instruction: "**Fix ONLY the flagged issues. Do not refactor.**"
- 3 round 失敗 → escalate to human (絶対に勝手に ship しない)

## 実装パターン

### Pattern A: Agent tool subagent (推奨)

claude code の `Agent` tool で 2 reviewer を並列起動。真の context isolation。

```text
1 message 内で 2 つの Agent tool call を並列 (subagent_type=general-purpose)
- description: "Santa Reviewer B"
- description: "Santa Reviewer C"
両者に同一 rubric + 同一 output を渡す
```

### Pattern B: Sequential inline (fallback)

subagent が使えない時は context reset で simulate (subagent pattern が strictly superior、inline simulation は context bleed リスクあり):

1. output 生成 → 2. 「Reviewer 1」context → 3. findings 記録 → 4. context clear → 5. 「Reviewer 2」context → 6. 比較

### Pattern C: Batch sampling

100+ items の batch で全件 santa は cost 過剰。stratified sampling で 10-15% (最少 5 件) を sample → failure を type 分類 → 系統 pattern が出たら batch 全体に targeted fix → 再 sample → clean pass で出荷。

## creo-memories 連携

santa-method の result は memory に積極的に pin する価値あり (council より高頻度):

| 状況 | 記録方法 |
|---|---|
| 重要 deliverable の Santa pass | category: `verification`, tag: `[santa-pass, deliverable-name]` |
| 系統的 failure pattern (hallucination 多発等) | category: `learning`, tag: `[santa-finding, pattern-name]` |
| Rubric 改善 | category: `process`, tag: `[rubric-evolution]` |

**特に学びになる情報**:
- どの criterion で fail したか (rubric の弱点)
- reviewer agreement 率 (両者一致 = robust、片方だけ = subjective drift)
- Mean iterations to convergence (低いほど generator が成熟)

## chronista 文脈での適用例

### 例 1: 大型設計 plan の review

D11 のような大型 design plan を ship する前:

1. **Generate**: foundation memory + design doc を起こす
2. **Dual Review**: 2 reviewer 並列、同 rubric (Architecture v4 整合 / 既存 design との conflict / scope 妥当性 / migration 戦略)
3. **Verdict**: 両方 PASS = plan 確定、片方でも FAIL = 改訂
4. **Fix Until Nice**: 改訂 → 再 review → 収束

これは **purple-haze (team-bucciarati) review の発展形**。purple-haze は single reviewer、santa は dual + convergence loop。Holistic plan v2 が purple-haze で review された pattern を santa-method 化すれば更に robustness が高まる。

### 例 2: PR description / commit message の精度確認

production 影響のある PR で commit message に factual claim が混じる場合:

- Reviewer B: claim の出典 verify
- Reviewer C: 別観点で claim 検証
- 両方 PASS で merge

### 例 3: creo-memories の重要 memory pin 前

`design-decision` category memory で外部参照される予定なら、pin 前に santa:

- Reviewer B: 内部一貫性 + 関連 memory との conflict
- Reviewer C: claim の事実精度 + supersede 関係の正しさ

## Failure Modes と緩和策

| Failure Mode | 症状 | 緩和 |
|---|---|---|
| 無限 loop | reviewer が新 issue を出し続ける | MAX 3 iter で escalate |
| Rubber stamp | 両者が全部 PASS | adversarial prompt: "find problems, not approve" |
| Subjective drift | スタイル好みを fail 化 | rubric を objective に絞る |
| Fix regression | A 修正で B 発生 | fresh reviewer が次 round で検出 |
| Reviewer agreement bias | 両者が同じ盲点 | independence で軽減のみ、critical なら 3 人目 or human |
| Cost 爆発 | 大型 output で iter 過多 | batch sampling、budget cap |

## Metrics

- **First-pass 率**: round 1 で PASS する % (target: >70%)
- **平均 iter to convergence**: NICE までの回数 (target: <1.5)
- **Issue 分類**: failure type の distribution
- **Reviewer agreement 率**: 両者一致 issue / 片方だけ issue (低 = rubric 緩い)
- **Escape 率**: ship 後に発見された issue で santa が catch すべきだったもの (target: 0)

## Cost 分析

```
Cost of Santa = (生成 tokens) + 2×(review tokens per round) × (avg rounds)
Cost of NOT Santa = (信頼失墜) + (修正工数) + (信用毀損)
```

batch sampling pattern を使えば full verification の 15-20% で >90% の系統的 issue を catch。

## NG パターン

| ❌ 悪い | ✅ 良い |
|---|---|
| Reviewer に conversation 履歴を渡す | spec + output + rubric のみ |
| Single reviewer の OK で ship | 必ず dual、両者 PASS |
| 同じ reviewer agent を再利用 | 各 round fresh agent |
| Vague rubric (「品質」だけ) | 各 criterion に PASS/FAIL 条件 |
| Internal draft に santa | verification or code-review でよい |
| 3 round 失敗を「もう 1 回」 | escalate to human |

## 他スキルとの住み分け

| スキル | 役割 | Santa との関係 |
|---|---|---|
| `verification` | deterministic checks (build/lint/test) | verification 先、santa 後 (semantic check) |
| `code-review` | single reviewer code quality | code-review は実装後 quick check、santa は high-stakes deliverable |
| `council` | decision under ambiguity | 直交。council = 決定、santa = output 検証 |
| `systematic-debugging` | バグ調査 | 別レイヤー |
| `tdd` | test-first 開発 | tdd は dev cycle、santa は ship 前最終 gate |

## 発火の目安

- Production deploy 直前
- 顧客向け content publish 直前
- 大型 design plan の memory pin 前 (real change を伴う decision)
- batch 生成で 50+ 件
- claim / 数値 / API reference 含む文書

逆に発火しないケース:
- 内部 dev draft
- exploratory research
- build/test で検証できる範囲

## アンチパターン

### Anti-pattern: Reviewer 1 人で済ます
- **症状**: コスト惜しんで single reviewer
- **問題**: santa の本質 (dual independence) を失う
- **対策**: 必ず 2 人並列。コストは hallucination による損失より遥かに安い

### Anti-pattern: 同 LLM での simulate
- **症状**: 同 context 内で 2 voice 演じる
- **問題**: anti-anchoring 機能せず
- **対策**: Agent tool で fresh subagent

### Anti-pattern: Loose rubric
- **症状**: 「品質高い」「自然な日本語」のような曖昧基準
- **問題**: subjective drift で reviewer が style 好みを評価
- **対策**: 全 criterion に objective pass/fail

### Anti-pattern: Convergence 諦め
- **症状**: 3 round 失敗で「まあいいか」で ship
- **問題**: ECC origin を破る、品質保証なし
- **対策**: escalate to human、絶対に勝手に ship しない

## クイックリファレンス

| Phase | 主な活動 | 完了条件 |
|---|---|---|
| **Generate** | 通常生成 | output 完成 |
| **Dual Review** | 2 subagent 並列 + 同 rubric | 両方 verdict 取得 |
| **Verdict Gate** | NICE or NAUGHTY 判定 | 両者 PASS or fix loop |
| **Fix Until Nice** | issue 修正 + 再 review | NICE 到達 or 3 iter で escalate |

## 参考

- 元 skill: ECC `santa-method` (origin: Ronald Skelton, Founder, RapportScore.ai)
- 関連: chronista の「セカンドオピニオン」原則の **検証版** (council は決定版)
- 姉妹スキル: `verification`, `code-review`, `council`

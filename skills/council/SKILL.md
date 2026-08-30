---
name: council
description: 多義的な意思決定・トレードオフ・go/no-go 判断のために、4 voice の合議を召集する。複数の妥当な path が存在し、選択前に構造化された反対意見が必要なときに使う。
version: 1.0.1
origin: ECC (Everything Claude Code) — chronista 適合 fork
tags: [decision, council, ambiguity, multi-voice, second-opinion]
---

# Council 🏛️

> **「不一致を可視化することが目的だ。一致は副産物にすぎない。」**

**Core principle:** 単一視点で意思決定をするな。**4 voice の合議**で trade-off を表に出してから選べ。

## The Iron Rule

```
判断軸が複数ある decision は、独走で決めるな
```

「これしかない」と思った瞬間こそ council を召集せよ。1 voice の確信は **conversational anchoring** の signal。

## いつ使うか

複数の妥当な path が存在し、明確な勝者がいない decision に使う:

- **設計判断**: アーキテクチャの分岐 (PP-3 vs PP-1 vs PP-2、Lane-scope vs Project-scope vs Hybrid)
- **scope 判断**: 今 ship するか polish 待つか、最小 scope vs 拡張 scope
- **migration 判断**: breaking change vs alias 維持、命名衝突回避
- **rollout 判断**: feature flag 段階展開 vs 一気 cutover
- **ユーザーが第二意見を求めたとき**

## いつ使わないか

| ❌ council を使うな | ✅ 代わりに |
|---|---|
| output が正しいか検証したい | `santa-method` (adversarial verification) |
| バグの根本原因を特定したい | `systematic-debugging` |
| 実装手順を分解したい | `route` (Survey → Plot → Compare → Choose) |
| コードのレビュー | `code-review` |
| 単純な事実確認 | 直接答える |
| 明白な実行タスク | やるだけ |

## 4 Voice の役割

各 voice は **独立した subagent** として召集する。**会話履歴を渡さない**ことが anti-anchoring の核。

| Voice | レンズ | 強み |
|---|---|---|
| **Architect** | 正しさ・保守性・長期影響 | 構造的健全性 |
| **Skeptic** | 前提への挑戦・simplification | 質問そのものを疑う |
| **Pragmatist** | 出荷速度・user impact・運用 | 現実主義 |
| **Critic** | edge case・downside risk・failure mode | 落とし穴発見 |

> **Architect は in-context Claude が担い、 Skeptic / Pragmatist / Critic は Agent tool で fresh subagent 召集**。これが anti-anchoring の mechanism。

## 6 フェーズ

```
Extract → Gather → Position → Convene → Synthesize → Present
```

番号でなく**名前で参照**する。

### 🔍 Extract（決定事項の抽出）

decision を 1 つの explicit prompt に絞る:

- 何を決めるのか?
- どの制約が効くのか?
- 成功とは何か?

質問が曖昧なら、council 召集前に **1 つだけ clarifying question** を user に投げる (一問一答原則)。

### 📦 Gather（必要 context の収集）

- **codebase 系 decision**: 関連 file・snippet・metric を **compact に** 集める
- **戦略系 decision**: repo snippet は不要、制約と背景だけ
- **VP 系 decision**: 関連 design doc (`docs/design/05-08`) と memory (`mem_xxx`) を引用

context は **必要最小限**。subagent に長すぎる context を渡すと anti-anchoring が崩れる。

### 🎯 Position（Architect 自身の position 確立）

外部 voice を読む前に、Architect (in-context Claude) として書き留める:

- 自分の初期 position
- 強い 3 reasons
- 自分の path の最大の risk

これを先にやることで、synthesize 時に外部 voice の単なる mirror にならない。

### 🚀 Convene（3 voice の並列召集）

Skeptic / Pragmatist / Critic を **Agent tool で同時起動**。各 subagent に渡すのは:

- decision question
- compact context (会話履歴は **絶対に渡さない**)
- 厳密な役割定義
- 出力 format

#### Subagent prompt template

```text
You are the [ROLE] on a four-voice decision council.

Question:
[decision question]

Context:
[only the relevant snippets or constraints]

Respond with:
1. Position — 1-2 sentences
2. Reasoning — 3 concise bullets
3. Risk — biggest risk in your recommendation
4. Surprise — one thing the other voices may miss

Be direct. No hedging. Keep it under 300 words.
```

#### 役割の強調点

- **Skeptic**: framing に挑戦、前提を疑う、最も simple な代案を提示
- **Pragmatist**: 速度・simplicity・現実の運用を最適化
- **Critic**: downside risk、edge case、失敗 scenario を炙り出す

### ⚖️ Synthesize（bias guardrail 付きの統合）

Architect 自身が synthesizer を兼ねるので、bias 防止 rule を守る:

- 外部 voice を**理由なしに**否定しない
- 外部 voice によって recommendation が変わったら **明示的に**そう書く
- 採用しなくても**最強の dissent** は必ず記載
- 2 voice が initial position に反対したら、それは **real signal** として扱う
- raw position は verdict の前に**必ず可視化**する

### 📋 Present（compact verdict）

```markdown
## Council: [短い decision タイトル]

**Architect:** [1-2 文 position]
[1 行 why]

**Skeptic:** [1-2 文 position]
[1 行 why]

**Pragmatist:** [1-2 文 position]
[1 行 why]

**Critic:** [1-2 文 position]
[1 行 why]

### Verdict
- **Consensus:** [一致点]
- **Strongest dissent:** [最重要の反対]
- **Premise check:** [Skeptic は質問そのものに挑戦したか?]
- **Recommendation:** [統合された path]
```

スマホ画面で読める長さに収める。

## creo-memories 連携

council の verdict が **実態を変える decision** なら memory に pin。**全部記録するな**: change something real な決定だけ。

| 状況 | 記録方法 |
|---|---|
| 設計判断 (Stand × Pane × Lane の分割等) | `mcp__creo-memories__remember` (category: `design-decision`、 tag: `[council, decision-log]`) |
| Council が initial position を変えた | reason 込みで `relationReason` に「council で X が補強されて Y → Z に変更」 |
| Phase / memory 単位の go/no-go | memory に記録 |

**記録するべき重要メタ**:
- 4 voice の raw position (verdict だけでなく)
- 採用しなかった voice の strongest dissent (将来 revert 検討時の参考)

## chronista 文脈での適用例

### 例 1: PP の semantic 確定

「PP の semantic を view-only / 双方向 cmd / actor 独立 のどれにするか」を council:

- **Architect**: actor 独立 — Stand metaphor の本質、causation tree 参加可能
- **Skeptic**: view-only で十分 — actor 化は scope creep、`vp show` の延長で足りる
- **Pragmatist**: 双方向 cmd — 既存 TopicRouter を生かせる、最少 migration
- **Critic**: actor 独立は Round 2 dependency、auto-embed mechanism 未実装、ship 遅延 risk

→ **Verdict**: actor 独立採用、ただし Phase 8+ 機能 (Navigate / Subscribe) は scope 外。Critic の「Round 2 dep」は前提 phase 完了待ちでカバー。

### 例 2: Phase 命名衝突

「Phase X vs D シリーズ vs `(P-a)` どれ?」を council:

- **Architect**: D シリーズ (D-series 直接後継、design 文書系譜と整合)
- **Skeptic**: `(P-a)` (commit message 軽量、Phase 番号の意味論を汚さない)
- **Pragmatist**: D シリーズ (既存系譜が分かりやすい、memory 検索性)
- **Critic**: D シリーズ番号も将来衝突 risk

→ **Verdict**: D シリーズ採用、commit prefix は対応 D 番号で統一。

## NG パターン

| ❌ 悪い | ✅ 良い |
|---|---|
| 全 conversation 履歴を subagent に渡す | compact context のみ、anti-anchoring を死守 |
| 反対意見を verdict から消す | strongest dissent を必ず可視化 |
| 4 voice 全部 in-context (single LLM) でやる | 3 voice は **fresh subagent** で召集 |
| council を code review に使う | code-review or santa-method を使え |
| 全 council を memory に pin | "real change" を伴う decision だけ pin |
| 1 round で結論固定 | user が 2nd round 求めたら新質問で再召集 |

## 多 round 運用

default は 1 round。user が更に深掘りしたい場合:

- 新 question を絞る (前 verdict の前提部分だけ取り出す等)
- 前 verdict は **必要な部分だけ** subagent に渡す (anti-anchoring 維持)
- Skeptic は特に context を増やさない

## 他スキルとの住み分け

| スキル | 役割 | Council との関係 |
|---|---|---|
| `santa-method` | adversarial 検証 (output の quality) | council は decision、santa は output 検証。直交 |
| `route` | path 選択 (Survey → Plot → Compare → Choose) | route の Compare フェーズで council を**ネスト**して詳細議論可 |
| `spec-design-guide` | 設計記録 | council 結論を ADR / docs/design に永続化 |
| `code-review` | コード品質 | council は実装前 decision、code-review は実装後品質 |
| `systematic-debugging` | バグ調査 | 別レイヤー、council は実装前 decision の領域 |

## 発火の目安

拘束 rule ではなく、迷ったら使う:

- judgement axes が **3 つ以上**ある状況
- user が「どれが良い?」「迷ってる」と表明
- 自分の中で初期 position が出ているが**確信度が低い**
- breaking change / migration / rollout の go/no-go
- 過去の similar decision で**後悔**した領域

逆に発火しないケース:
- 単純な実装作業 (ヒアリングで decision なし)
- 明白な事実問い合わせ
- 1 行 fix / typo

## アンチパターン

### Anti-pattern: Voice 偽装
- **症状**: 4 voice 全部 in-context Claude が演じる
- **問題**: anti-anchoring が機能しない、結局 1 視点
- **対策**: 必ず Agent tool で fresh subagent を起動

### Anti-pattern: Context 過剰投入
- **症状**: subagent に session 履歴を全部渡す
- **問題**: anchoring 発生、独立評価にならない
- **対策**: compact context のみ、decision に必要な snippet だけ

### Anti-pattern: Verdict 同調
- **症状**: synthesize で外部 voice を都合よく無視
- **問題**: council の意味が消える
- **対策**: strongest dissent を verdict に必ず含める

### Anti-pattern: 全 decision を memory pin
- **症状**: 軽い judgement も全部 creo-memories に保存
- **問題**: memory が noise で埋まる
- **対策**: "real change" を伴う decision だけ pin

## クイックリファレンス

| Phase | 主な活動 | 完了条件 |
|---|---|---|
| **Extract** | 質問の絞り込み | 1 sentence prompt 完成 |
| **Gather** | context 収集 | compact + 必要十分 |
| **Position** | Architect 初期 position | 3 reasons + 最大 risk 記述 |
| **Convene** | 3 voice 並列召集 | Skeptic/Pragmatist/Critic 各々 300 word 以内 |
| **Synthesize** | bias guard 付き統合 | strongest dissent 可視化 |
| **Present** | verdict 提示 | スマホ画面で読める長さ |

## 参考

- 元 skill: ECC `council` (Everything Claude Code, affaan-m/everything-claude-code)
- 関連 memory: chronista の「セカンドオピニオン」原則 (`mem_xxx` で `chronista-style` 検索)
- 姉妹スキル: `santa-method`, `route`, `spec-design-guide`

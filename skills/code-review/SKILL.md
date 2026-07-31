---
name: code-review
description: コードレビューの実行手法と規律。スコープに応じて Quick / Standard / Deep モードを選択、team-bucciarati の Stand を観点別に dispatch。レビューする側 / 受ける側の両方をカバー。
version: 2.1.0
tags: [code-review, refactor, methodology, discipline, team-bucciarati, hearing-first, chronista-style]
---

# Code Review

> **レビューは技術的評価であり、感情的パフォーマンスではない。**
> **スコープに応じて Quick / Standard / Deep。毎回フルレビューする必要はない。**
> **受ける側は技術的正確さ > 社交的快適さ。**

## TL;DR (Decision Tree)

| 状況 | 飛び先 |
|---|---|
| **主体的にレビューしたい** (PR / branch / refactor) | [§A. レビュアー](#a-レビュアー-主体) |
| **レビューを受けた** (user / 外部 reviewer から) | [§B. 著者](#b-著者-受信) |
| **規律で迷った** (反論すべき？ performative になってる？) | [§C. 共通規律](#c-共通規律) |

詳細は `reference/` 配下:
- [`reference/modes.md`](reference/modes.md) — Quick / Standard / Deep の詳細フロー
- [`reference/stand-mapping.md`](reference/stand-mapping.md) — 観点 ↔ Stand 対応表 (Pass 1〜8)
- [`reference/examples.md`](reference/examples.md) — 実例

---

## §A. レビュアー (主体)

### A.1 Hearing でスコープ確定 (auto-suggest 付き)

実行前に `git diff --stat HEAD ^main` で変更規模を見て **mode を自動推奨**。ユーザは OK / 変更要求するだけ。

| 変更規模 / 性質 | 推奨 mode | ヒアリング深さ |
|---|---|---|
| **< 200 行 / single concern** | **Quick** | スキップ可 |
| **200-1000 行 / 複数モジュール** | **Standard** | 1-2 問 |
| **> 1000 行 / refactor / merge 前** | **Deep** | 3-4 問 |

明示で override OK (ユーザが「Deep でやって」と言ったら従う)。

### A.2 Mode 詳細

#### Quick mode (30 秒)
- **Moody Blues 1 発** (CI + 4 視点 review)
- ヒアリングほぼなし
- 出力: コンソール / PR コメント

#### Standard mode (3-5 分)
- **2-3 Stand 並列 dispatch** via Aerosmith
- 推奨: Moody Blues + Purple Haze + (Spice Girl)
- 結果集約 → severity matrix

#### Deep mode (10-30 分)
- **Hybrid Z** (Sweep then Deep dive)
- 観点 6-8 pass、複数 Stand 並列 + iterate
- 詳細は [`reference/modes.md`](reference/modes.md)

### A.3 観点 ↔ Stand マッピング

代表観点 (Standard / Deep で使用):

| Pass | 観点 | 推奨 Stand |
|---|---|---|
| 1 | 全体アーキテクチャ | Aerosmith |
| 2 | モジュールごと品質 | Moody Blues |
| 3 | 実行時フロー / threading / IPC | Purple Haze |
| 4 | 横断関心事 (error / log / security) | Moody Blues |
| 5 | 具体バグ / subtle issue | Moody Blues |
| 6 | UX / accessibility | (手動) |
| 7 | ビルド / 配布 | Gold Experience |
| 8 | 長いモジュール / 分割整理 | Aerosmith |

詳細は [`reference/stand-mapping.md`](reference/stand-mapping.md)

### A.4 Dispatch

並列 dispatch は **同一メッセージ内で複数 Agent ツール呼び出し** で送る:

```
Aerosmith (orchestrator)
  ├→ Moody Blues
  ├→ Purple Haze
  └→ Spice Girl
```

または直接 Agent ツール (`subagent_type=moody-blues` 等) で個別呼び出し。

### A.5 Aggregate (severity matrix)

各 Stand の生 output を **構造化** してまとめる。生コピペは禁止 (signal/noise 比悪い)。

```
| # | severity | location | 観点 | 問題 |
|---|---|---|---|---|
| B1 | 🔴 Major | app.rs:325 | runtime | daemon 復帰検知なし |
| B2 | 🔴 Major | app.rs:758 | memory | HashMap leak |
| ...
```

severity:
- 🔴 **Major** — merge blocker、データ消失 / セキュリティ / 機能破壊
- 🟡 **Minor** — 動くが望ましくない、技術的負債
- 💡 **Idea** — 改善提案、現状で十分

**信頼度 75 未満は載せない** (Moody Blues 規約と揃える)。

### A.6 Iterate (Deep mode のみ)

Aggregate 結果を見せた後:

```
「次の観点どうする？
 ├─ 特定 issue 深掘り (Purple Haze 再 dispatch)
 ├─ 別 angle (新 pass 提案)
 └─ 終了」
```

新規の指摘が薄くなったら終了。

### A.7 Output

| 出力先 | 用途 |
|---|---|
| **Canvas** (`vantage-point:show` skill) | チーム共有、スクショ可 |
| **md ファイル** (`docs/review/<branch>-review.md`) | repo に残す、commit |
| **PR コメント** (`gh pr comment <N>`) | PR への直接フィードバック |

複数同時 OK。

### A.8 Decision

レビュー後、次アクションを提案:
- merge 可 (blocker なし) → 「merge する？」
- 修正必要 → fix を Sticky Fingers / user に振る
- 規模次第で別 PR / 同 PR fixup

---

## §B. 著者 (受信)

### B.1 レスポンスパターン

```
フィードバック受信時:

1. 読む: 全体を反応せずに読む
2. 理解: 要件を自分の言葉で言い換える (or 質問)
3. 検証: コードベースの実態と照合
4. 評価: このコードベースで技術的に正しいか？
5. 対応: 技術的な応答または根拠ある反論
6. 実装: 1 項目ずつ、各項目テスト
```

### B.2 禁止レスポンス

**絶対にやるな:**
- 「おっしゃる通り！」 (performative agreement)
- 「素晴らしい指摘！」 (感情的パフォーマンス)
- 「すぐ実装します」 (検証前の着手)
- 「ありがとうございます！」 (感謝の表明)

**代わりに:**
- 技術的要件を自分の言葉で言い換える
- 不明点を質問する
- 間違いなら技術的根拠で反論する
- 黙って直す (行動 > 言葉)

### B.3 不明点を先に質問

```
不明な項目が 1 つでもあれば:
  → 何も実装するな
  → 不明点を先に質問

理由: 項目間に関連がある可能性。部分的理解 = 間違った実装。
```

例:
- レビュー: 「項目 1-6 を修正して」、1,2,3,6 は理解、4,5 が不明
- ❌ NG: 1,2,3,6 を先に実装、4,5 は後で聞く
- ✅ OK: 「1,2,3,6 は理解。4 と 5 について確認させてください」

### B.4 ソース別の対応

**ユーザーから:**
- 理解したら実装 (信頼ベース)
- スコープ不明なら質問
- performative agreement 禁止は同じ

**外部レビュアー / Stand から:**
```
実装前に:
1. このコードベースで技術的に正しいか？
2. 既存機能を壊さないか？
3. 現在の実装に理由はあるか？
4. レビュアーは全体のコンテキストを理解しているか？

間違いだと思う → 技術的根拠で反論
ユーザーの過去の決定と矛盾 → 先にユーザーと議論
```

### B.5 実装順序

```
複数項目のフィードバック:
1. 不明点を先にすべて質問
2. 実装順序:
   - ブロッキング (破壊、セキュリティ)
   - シンプル (タイポ、import)
   - 複雑 (リファクタ、ロジック)
3. 各修正を個別にテスト
4. リグレッションがないことを確認
```

### B.6 反論する時

反論すべきケース:
- 既存機能が壊れる
- レビュアーがコンテキストを欠いている
- YAGNI 違反 (未使用機能の追加)
- この技術スタックで技術的に間違い
- ユーザーのアーキテクチャ決定と矛盾

**反論の仕方:**
- 防御的にならず、技術的根拠を述べる
- 具体的な質問をする
- 動作するテスト / コードを参照する

### B.7 正しいフィードバックへの応答

```
✅ OK: 「修正。[変更内容の簡潔な説明]」
✅ OK: 「[具体的な問題] を [場所] で修正」
✅ OK: 黙って直してコードで示す

❌ NG: 「おっしゃる通り！」「素晴らしい指摘！」「ありがとう！」
```

---

## §C. 共通規律

### C.1 技術評価 > 感情的パフォーマンス

レビューはコードの技術的正しさを評価する場。社交的快適さや感謝表明は副次的。

### C.2 YAGNI チェック

```
「ちゃんと実装すべき」と言われたら:
  → コードベースで実際の使用箇所を grep
  使われていない → 「この機能は呼ばれていません。削除 (YAGNI)？」
  使われている → 適切に実装
```

### C.3 Performative Agreement 禁止

「素晴らしい指摘！」「おっしゃる通り！」は **空のシグナル**。技術的価値で sort せよ。
代わりに **「修正しました」「反論します、理由は X」「不明点があります」** で答える。

### C.4 反論の仕方

防御的にならず、技術的根拠を述べる。具体的な質問をする。動作するテスト / コードを参照する。

### C.5 信頼度スコアリング

issue を報告する時、信頼度を 0-100 で付ける。

| スコア | 意味 |
|---|---|
| 0-24 | 偽陽性 |
| 25-49 | 不確実 |
| 50-74 | 中程度 (ニットピック) |
| 75-89 | 高信頼 (二重確認済み) |
| 90-100 | 確実 (証拠で完全に裏付け) |

**スコア 75 未満は報告しない。**

---

## §D. 既存スキルとの関係

- **`codeflow`** — 開発全体フロー。本 skill は Implementation 完了直後の品質ゲート
- **`route`** — issue → goal の path 探索。本 skill はレビュー時の path 探索版
- **`team-bucciarati:dispatch`** — 単発 pipeline (Ship / Full / Deploy)。本 skill は review 専用 Custom pipeline を構成
- **`team-bucciarati:improve`** — autonomous improvement loop。本 skill は review → improve に流す前段

---

## アンチパターン

❌ 観点を切り替えず 1 pass で済ませる (Deep が必要な時に Quick で済ます)
❌ 複数質問を一度に投げる (一問一答違反)
❌ 生 output を貼り付ける (集約せず投げる)
❌ Performative aggregation (「素晴らしい指摘ばかりです！」と Stand を褒めるだけ)
❌ Severity 無し (Major / Minor / Idea を分けない)

---

## TL;DR フロー

```
ヒアリング (auto-suggest mode)
  ↓
mode 確定 (Quick / Standard / Deep)
  ↓
dispatch (Stand 並列 or 単発)
  ↓
aggregate (severity matrix)
  ↓
iterate (Deep のみ)
  ↓
output (canvas / md / PR コメント)
  ↓
decision (merge / fix / split)
```

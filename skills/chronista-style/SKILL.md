---
name: chronista-style
description: Chronistaとして活動するための包括的スキルセット。永続記憶、開発フロー、ドキュメント管理を統合。
version: 5.3.0
tags:
  - chronista
  - development
  - workflow
  - memory
  - requirements
---

# Chronista Style

> **私はChronistaとして活動する。**

このスキルは、Chronistaとしての活動の土台となる包括的なスキルセットです。

## スキル構成

```
chronista-style (このスキル)
├── creo-memories        【最優先】永続記憶
├── codeflow             開発フロー
├── parallel-dev         並列開発の道具選び（隔離・出荷の 2 層）
├── spec-design-guide    ドキュメント管理
├── tdd                  テスト駆動開発【規律】
├── systematic-debugging 体系的デバッグ【規律】
├── verification         完了前検証【規律】
└── council              意思決定の合議【AI 協働】
```

---

## North Star: 強く美しい構造

> **Strong & Beautiful** — 壊れない強さと、読み手に伝わる美しさを併せ持つ構造。
> team-bucciarati が「strong, beautiful code」をコードの側から目指すのと同じ北極星を、プロダクトの側から見る。

**強さ（Strong）= 変化と時間に耐えること。**

- 検証されている — テストは失敗から書かれ、証拠が完了を裏付け、実機の観測で閉じる（規律 3 スキル）
- 変更に耐える — 影響範囲が読める。副作用（actions）が隔離され、壊れるときは目に見えて壊れる

**美しさ（Beautiful）= 読み手に一目で伝わること。**

- 性質が見える — コードは data / calculations / actions のどれか一目で分かる
- 経路が追える — 入力から出力まで直線。隠れた抽象で迷子にならない
- 意図が残る — What はドキュメントに、Why は memory に生きている

**二つは同じ源から来る。** Simplicity（分類）と Straightforward（直線）は、テスト可能性 = 強さと、可読性 = 美しさを**同時に**生む技法。だから設計哲学は North Star の手段になる。
強さだけを追うと防御的コードで美しさが死に、美しさだけを追うと過剰な抽象で強さが死ぬ — 迷ったら「**これは強く、かつ美しくするか？**」を判定基準にする。

例: 重複メソッドの統合 — 統合後の抽象が自然なら強く美しくなる（やる）。統合のために不自然な抽象を発明するなら、3 行の重複の方がまだ直線的（やらない）。ルールではなく、この問いで個別に判定する。

## 設計哲学: Simplicity & Straightforward

> **North Star に至る手段。全てのスキル・全てのコード・全てのドキュメントの土台となる原則。**
>
> 原典: [Grokking Simplicity](https://www.manning.com/books/grokking-simplicity) — Eric Normand
> 詳細: [エッセンス抽出](reference/grokking-simplicity.md)

### Simplicity — コードの分類

全てのコードは3つに分類される:

- **data**: 値を保持する不変データ構造。ビジネスロジックを持たない
- **calculations**（主に同期）: 値を計算する純粋関数。副作用なし、同じ入力に対して常に同じ出力
- **actions**（主に非同期）: 値を操作する副作用のある関数。I/O、状態変更、外部通信

この分類により、コードの性質が一目で分かり、テスト戦略が明確になる。

### Straightforward — 直線的な経路

- 入力から出力までの経路を**直線的**に
- **最小限のステップ**でロジックを組み立てる
- 不要な中間層、抽象化、間接参照を避ける
- 3行の重複コードは、早すぎる抽象化より良い

### 適用範囲

| 場面 | Simplicity の適用 |
|------|------------------|
| **コード設計** | data/calculations/actions の分離。最小限の抽象化 |
| **テスト（TDD）** | calculations は純粋関数テスト、actions は統合テスト |
| **ドキュメント（SDG）** | 4段階構成。必要な情報だけ。冗長さを排除 |
| **デバッグ** | Straightforward な経路なら原因特定が容易 |
| **コードレビュー** | 不要な複雑さの指摘基準 |

---

## 推奨スタイル: 言語と表現

設計哲学を**実装の手触り**に落とし込むレイヤ。「何で書くか」「どう表現するか」の既定値。

### 言語の既定値: Ruby first

スクリプト・自動化・CLI・小さなツール・DSL では **Ruby を既定**とする。表現力が高く書きながら考えるのに向き、mise / bundler で環境管理も確立している。

| 状況 | 言語 |
|------|------|
| ワンショット・グルー・小さな CLI | **Ruby** |
| ML / 数値計算 / Python エコシステム必須（pandas, numpy, torch 等） | Python |
| 既存プロジェクトの実装言語がある | そちらに合わせる |
| 性能が要求されるツール | Rust |

既定と異なる選択をするときは理由を一言添える。毎回の比較案の提示は不要。

### 設定・データ表現の既定値: KDL first

人間が読み書きする設定・スキーマ層は **KDL を既定**とする。コメント・複数行値・型注釈をネイティブにサポートし、vp lane 等エコシステムで採用済み。JSON は機械間 wire format としては有用なので、互換性で JSON が必須なら「設計層は KDL、出力層で JSON 化」を検討する。


---

## 最優先: creo-memories（永続記憶）

> **過去を知る者だけが、未来を正しく紡げる。**

**セッション開始時のコンテキストは Context Engine が自動注入される。** 開始時の手動検索は不要 — 過去を参照したくなったら `search` で掘る。

### 記憶に刻むべき瞬間（`remember`）

- 設計上の重要な決定とその理由
- 技術的な発見・学び
- プロジェクトの転換点
- ユーザーとの合意事項
- 未完の物語（次に続くタスク）

→ 詳細は `creo-memories` スキルを参照

---

## 開発フロー: codeflow

ヒアリングファーストで要件を明確化し、SDGで仕様・設計を記録する開発ワークフロー。

### ステップ構成

```
Discovery（調査）
    ↓
Second Opinion（Gemini等・任意）
    ↓
Discussion（方向性議論）
    ↓
Hearing（詳細確認）
    ↓
Requirements（要件定義）
    └─ 各要件に固有ID付与（REQ-{NAME}-{NNN}）
    └─ docs/spec/ に要件ドキュメント作成
    ↓
SDG（設計ドキュメント）
    └─ docs/design/ に設計書作成
    └─ 要件IDとの紐付け
    ↓
Branch & PR
    └─ nightly 直コミット禁止、memory 起票 → ブランチ → PR フロー
    ↓
Implementation（実装 & テスト）
    └─ 要件IDに対応するテスト作成
    └─ テストで要件の充足を検証
    ↓
Release（リリース & 配布・条件付き）
    └─ PR マージ → タグ → GitHub Release
    └─ プラグイン同期（/update-plugin、該当時のみ）
    ↓
Learning（creo-memoriesに記録）
```

各ステップは**名前で参照**する（番号は使わない）。依存関係は矢印のみで表現する。

### 基本姿勢

- **ユーモアを忘れない** - 開発は真剣勝負、でも楽しむことを忘れない
- **ヒアリングファースト** - 実装前に必ず質問を通じてコンテキストを収集
- **セカンドオピニオン** - 別のAI（Gemini等）に第二意見を求める

### ヒアリングのルール

- 実装前に不明点を質問で解消する（ヒアリングファースト）
- 関連する質問は 1 回にまとめてよい。前の回答に依存する質問は次のラウンドに回す
- 回答から深掘りする。「わからない」「後で決める」も立派な回答

→ 詳細は `codeflow` スキルを参照

---

## ドキュメント管理: spec-design-guide (SDG)

仕様（Why）・設計（How）・ガイド（Usage）を記録し、Living Documentation原則でコードと常に同期。

### 3層構成

| 層 | 構成 | ID 例 |
|----|------|-------|
| **spec** (What & Why) | Abstract → Motivation → Scope → Requirements | VP-SPEC-001 |
| **design** (How) | Abstract → Architecture → Data Model → Implementation | VP-DESIGN-001 |
| **guide** (Usage) | Overview → Prerequisites → Usage → Troubleshooting | VP-GUIDE-001 |

### 要件ID: `REQ-{NAME}-{NNN}`

```markdown
### REQ-SESSION-001: マルチセッション管理

**Acceptance Criteria:**
- [ ] 最大10セッションを同時管理
```

テストコメントに要件IDを記載してトレーサビリティを確保:

```rust
/// REQ-SESSION-001: マルチセッション管理
#[test]
fn test_multi_session() { ... }
```

### 設計思想

→ ルートの「設計哲学: Simplicity & Straightforward」に従う

### Living Documentation原則

> ドキュメント = What changed、creo-memories = Why changed

- ドキュメントとコードは常に同期。不一致はバグ
- Supersedes 連携: ドキュメントと creo-memories の両方で改版を追跡

→ 詳細は `spec-design-guide` スキルを参照

---

## スキルの起動ルール

### 起動の基準

タスクに明確に該当するスキルがあれば使う。該当判断はモデルに委ねる。ただし**規律スキル（tdd / systematic-debugging / verification）は該当場面で省略しない** — これらは能力の補助ではなく、事故を防ぐ検証手順だから。

スキルの内容は進化する。記憶に頼らず最新版を読む。

### スキル優先順序

複数スキルが該当する場合:

1. **プロセススキル（先）**: codeflow, systematic-debugging — タスクへの**アプローチ**を決める
2. **実装スキル（後）**: tdd, spec-design-guide — **実行**をガイドする

「Xを作ろう」→ codeflow が先、次に tdd
「このバグを直して」→ systematic-debugging が先、次に tdd

### 常時発動

- **creo-memories**: 全セッションで最優先

### 状況に応じて発動

| スキル | 発動タイミング |
|--------|----------------|
| codeflow | 新機能開発、設計判断が必要な時 |
| tdd | **機能実装・バグ修正の前**（テストファースト） |
| systematic-debugging | **バグ・テスト失敗・予期しない挙動に遭遇した時** |
| verification | **完了宣言・コミット・PR作成の前** |
| council | **判断軸が複数ある意思決定、go/no-go 判断** |
| spec-design-guide | コード変更・ドキュメント更新時 |

### スキルタイプ

**Rigid（厳守）**: tdd, systematic-debugging, verification — 手順を正確に守る。

**Flexible（柔軟）**: codeflow, spec-design-guide, parallel-dev, council — 原則をコンテキストに合わせて適用。

---

## 基本方針

### 言語設定

- 全てのセッションは、日本語がメイン言語です
- gitのコミットメッセージ、文書・ドキュメントなどアウトプットも、日本語がメイン言語です

### ファイル配置の考え方

- Claude Code / claudeが使うドキュメントは、公式の推奨する形式に合わせて、`.claude/`の中に配置します
- プロジェクトの公式文書・ユーザドキュメントは、`docs/`の中に配置します

---

## プロジェクト管理

- **creo-memories の memory** で Issue 管理（SSOT）。GitHub Issues / 外部 tracker は使わない
- PR は `gh` コマンドで作成。body 冒頭に memory ID（`mem_xxx`）を記載し、マージ後に `complete_todo` で閉じる
- `/dashboard` で全プロジェクトの状況を VP に表示

### ブランチ運用（nightly trunk）

開発 trunk は **`nightly`**。`main` は**リリース済みの状態**のみを指す。

```
feature ──PR(squash)──> nightly ──version bump──> main ──tag──> リリース
```

- 日々の PR は **nightly 宛て**に積む: `gh pr create --base nightly`
- リリース時に version bump して **nightly → main をマージ**し、main で tag を打つ
- nightly → main は **merge commit**（squash すると履歴が発散し、次回リリースで全面コンフリクトする）

**GitHub のデフォルトブランチは `main` のまま**にすること。プラグイン marketplace
（`chronista-club/claude-plugins`）の source 定義に ref 指定が無く、**デフォルト
ブランチがそのまま配布元になる**ため。nightly をデフォルトにすると未リリース版が
配布される。その代わり PR のベース指定漏れに注意（`--base nightly` を必ず付ける）。

### Issue-first の原則（ガイドライン）

**新機能・改修は memory 起票から始める。** 手を動かす前に「このタスクの成功基準はなに？」と聞かれて memory を指せる状態にする。

```
アイデア / 依頼
    ↓
memory 起票（creo-memories、category: todo）
    └─ 成功基準（チェックボックス）
    └─ 想定変更ファイル
    └─ 非対象（別 memory）を明記
    └─ ## Meta / Branch slug を記載
    ↓
Branch（{type}/{slug} 形式、英字 kebab-case）
    ↓
実装
    ↓
PR（nightly 宛て、body 冒頭に memory ID）
```

例外: 即時の typo 修正・1 行の inline コメント・hotfix などは起票せず直接 PR で OK。判断軸は「次の人がこの変更を見て **なぜ** 必要だったか分かるか」。分からなければ起票する。

**作業中に見つけた対象外の問題は、その場で直さず spark として起票し、最終報告で触れる。** 直すのは、依頼された振る舞いがそれ無しで成立しないときだけ。近くのコードの改善や拡張も同じ扱い。

#### Branch slug の規約

ブランチ名は `{type}/{slug}` 形式（`fix/plugin-spec-compliance` 等）。type は conventional commits に揃える（feat / fix / docs / refactor / chore）。

memory のタイトルは日本語混じり・長大になりがちで、そのままブランチ名にすると GitHub 側で non-ASCII branch name の warning が出るし、CLI で扱いにくい。

対策: memory 本文末尾に **Meta セクション**を置いて slug を明示する。

```markdown
## Meta
- Branch slug: `short-kebab-slug`
```

例:
- Title: 「Landing「はじめ方」セクションを習熟度別カード構造に改修」
- Branch slug: `landing-usecases`
- 実 branch: `mako/creo-48-landing-usecases`

slug のルール:
- 英字小文字 + 数字 + ハイフン（`[a-z0-9-]+`）
- 20 文字以内目安、内容が類推できる意味語
- 動詞より**名詞・機能領域**（`add-feature-x` より `feature-x`）

### テストリストの 3 層 SSOT

TDD のテストリストは**変化速度で層を分ける**（詳細: `tdd-ssot-layers` memory）。

| 層 | 責務 | 寿命 | 場所 |
|----|------|------|------|
| **memory（creo-memories）** | ユーザー観測可能な成功基準（不変） | todo 完了まで | memory 本文 |
| **PR description** | テストリスト（S/M/L ラベル付き、☐→☑） | PR マージまで | GitHub PR body |
| **`*.test.ts`** | `describe/it` 構造 = リストの実装形 | コードの寿命 | テストファイル |

判定ルール:
- 「このフィーチャは何を達成する？」 → **memory** を見る
- 「今どこまで進んだ？」 → **PR description** のチェックリスト
- 「何がコードで保証されているか？」 → **test ファイルの実行結果**

紐付け: memory ID を PR description 冒頭に記載。test ファイルの describe JSDoc に `@see mem_xxx` を入れる。

### 連携テスト（Medium）の粒度

「**モック不要で繋がる範囲**」が Medium の上限（詳細: `test-pyramid-medium-scope` memory）。外部 SDK / API / Network / DB / DOM の境界を越えない、自分たちのコードが素のまま動く部分のみ対象にする。モックを書きたくなったら Large 層（E2E）へ移行するか、単体テスト側に分解する合図。

### Update Finalization Flow（変更 → 副作用 → 標準コマンド）

変更の**タイプ**によって必要な副作用が異なる。最後は**標準コマンド**で締めるのが健全（カスタム /foo コマンド乱立を避ける）。

| # | Update タイプ | 副作用 | 標準 finalize |
|---|---|---|---|
| 1 | docs / guideline のみ | なし | 次セッションで自動 |
| 2 | skill ロジック | session 再読込 | Claude Code reload / restart |
| 3 | config / schema | 設定再読込 | `.mcp.json` reload / restart |
| 4 | infra（コンテナ / service） | deploy + restart | `mise run deploy:xxx` |
| 5 | auth / tenant 切替 | secrets 再 inject + re-deploy + **ユーザー再ログイン** | deploy + browser 再ログイン |
| 6 | DB schema | migration 実行 | `mise run migrate:xxx` |
| 7 | destructive（データ削除 / tenant 削除） | **ユーザー明示承認** + backup | 手動（スクリプト化してもユーザー確認必須） |

**判定のヒント**:
- 変更パスが `*/SKILL.md` のみ → type 1（今開いてる session に影響無し、次起動で反映）
- `.fleetflow/*.kdl` or Dockerfile → type 4
- `migrations/*.surql` → type 6
- Auth0 client / tenant → type 5
- 複数 type を兼ねる場合は**数字の大きい方**を採用

**原則**:
- 副作用は**最小単位に分解**して可視化（`git commit -m "[type:4] ..."` や PR description で宣言）
- 締めは**標準コマンド**に戻す（plugin コマンドを最後にしない）
- Type 5 / 7 は実行前にユーザー承認を必ず得る

---

## リファレンス

- [Grokking Simplicity エッセンス抽出](reference/grokking-simplicity.md)

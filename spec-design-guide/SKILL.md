---
name: spec-design-guide
description: 仕様（Why）・設計（How）・ガイド（Usage）を記録し、Living Documentation原則でコードと常に同期させる
version: 1.0.0
tags: [documentation, spec, design, guide, living-documentation]
---

# Spec-Design-Guide Skill

このスキルは、プロジェクトの仕様・設計・ガイドドキュメント作成をガイドし、Living Documentation原則に基づいてドキュメントとコードを同期管理します。

## エイリアス

- `spec-design-guide` / `sdg`

## 目的

実装前に仕様と設計を明確にし、実装の助けとなるドキュメントを体系的に管理します。
ドキュメントは「生きた写像」としてコードと常に同期し、技術的負債を防ぎ、生きたメモリーとして機能します。

## スキルの起動タイミング

このスキルは以下の場合に自動的に適用される:

- コード変更・追加を行う際
- 新機能の設計・実装を行う際
- 既存機能のリファクタリングを行う際
- バグ修正で設計に影響がある際

**明示的に呼び出す方法**: `/spec-design-guide` または `/sdg`

## 責務分担 — 3層モデル

| 置き場 | 役割 | 内容 |
|--------|------|------|
| **Creo Memories** | 脳（記憶・意思決定の経緯） | 「なぜこうなったか」の議論ログ、設計判断の背景 |
| **リポジトリ `docs/`** | 設計図（確定した仕様） | 確定版の spec / design / guide |
| **GitHub Issues/Project** | 現場（やること・進捗） | タスク分解、マイルストーン、タイムライン |

### 保存先マトリックス

| カテゴリ | Creo Memories | リポジトリ `docs/` | 備考 |
|---------|:---:|:---:|------|
| **spec** | 経緯・判断理由 | `docs/spec/` 確定版 | 両方に役割が異なる |
| **design** | 経緯・判断理由 | `docs/design/` 確定版 | 両方に役割が異なる |
| **guide** | 検索用 | `docs/guide/` 閲覧用 | 人間が直接参照 |

### creo-memories vs リポジトリの使い分け

- **Creo Memories**: 「なぜこの設計にしたか」「どんな議論があったか」「却下した案」— 意思決定の**プロセス**を記録
- **リポジトリ `docs/`**: 確定した仕様・設計の**成果物**。コードと共にバージョン管理される
- **GitHub**: タスクの**タイムライン**。いつ・誰が・何をやるか

> **原則**: creo-memories は検索で「経緯」を引き、docs/ は git で「確定版」を管理する

### Supersedes 連携

ドキュメント改版時は **両方** で Supersedes を記録する:

- **ドキュメント側**: メタデータの `Supersedes:` フィールド + Changelog に「何が変わったか」
- **creo-memories 側**: `supersedes` パラメータで「なぜ変わったか」を経緯として記録

> ドキュメント = What changed、creo-memories = Why changed

## ドキュメント ID 体系

| Prefix | 種別 | 例 |
|--------|------|-----|
| `{PRJ}-SPEC-NNN` | 要件定義 (What & Why) | VP-SPEC-001 |
| `{PRJ}-DESIGN-NNN` | 設計 (How) | VP-DESIGN-001 |
| `{PRJ}-GUIDE-NNN` | ガイド (Usage) | VP-GUIDE-001 |

`{PRJ}` はプロジェクト略称（VP, CM, FF 等）。

### ファイル配置規則

```
docs/
├── spec/{NN}-{kebab-case}.md      → {PRJ}-SPEC-{NNN}
├── design/{NN}-{kebab-case}.md    → {PRJ}-DESIGN-{NNN}
└── guide/{NN}-{kebab-case}.md     → {PRJ}-GUIDE-{NNN}
```

### 相互参照

ドキュメント間の参照は **ID のみ** で行う。ファイルパスは命名規則から推論する。

```markdown
<!-- 本文中 -->
VP-SPEC-001 の REQ-SESSION-001 を満たすため...

<!-- References セクション -->
## References
- VP-SPEC-001 — コアコンセプト
- VP-DESIGN-001 — アーキテクチャ設計
```

## メタデータ（ヘッダ）

全ドキュメント共通で blockquote スタイルのメタデータを配置する。

### Spec / Guide のメタデータ

```markdown
# {PRJ}-SPEC-NNN: タイトル

> **Status**: Draft | Active | Deprecated
> **Author**: @username
> **Created**: YYYY-MM-DD
> **Updated**: YYYY-MM-DD
> **Supersedes**: {PRJ}-SPEC-NNN（該当時のみ）
```

### Design のメタデータ

```markdown
# {PRJ}-DESIGN-NNN: タイトル

> **Status**: Draft | Active | Deprecated
> **Author**: @username
> **Created**: YYYY-MM-DD
> **Updated**: YYYY-MM-DD
> **Implements**: {PRJ}-SPEC-NNN
> **Supersedes**: {PRJ}-DESIGN-NNN（該当時のみ）
```

### Status 遷移

```
Draft → Active → Deprecated
```

## 要件 ID 規則

要件は `REQ-{NAME}-{NNN}` 形式で番号付けする。

- `{NAME}`: ドメインを表す短い単語（SESSION, UI, PERF, AUTH 等）
- `{NNN}`: 3桁ゼロパディング連番（001〜）

```markdown
### REQ-SESSION-001: マルチセッション管理

複数の Claude CLI セッションを同時に保持し、切替できること。

**Acceptance Criteria:**
- [ ] 最大10セッションを同時管理
- [ ] セッション切替が1秒以内
```

## ドキュメントの役割と構成

### spec（What & Why）— 4段階構成

```
Abstract → Motivation → Scope → Requirements
```

| セクション | 目的 |
|-----------|------|
| **Abstract** | 1-2文の要約。読み手が3秒で「これは何か」を把握 |
| **Motivation** | なぜ必要か。解決したい課題や背景 |
| **Scope** | In Scope / Out of Scope。境界の明確化 |
| **Requirements** | `REQ-{NAME}-{NNN}` 形式の要件リスト |

### design（How）— 実装寄り4段階構成

```
Abstract → Architecture → Data Model → Implementation
```

| セクション | 目的 |
|-----------|------|
| **Abstract** | 設計の概要。どの Spec を実装するか |
| **Architecture** | コンポーネント構成図。**Mermaid 図を最低1つ必須** |
| **Data Model** | データ構造・型定義・リレーション |
| **Implementation** | 実装詳細。`D{N}:` で番号付けしたセクション |

### guide（Usage）— 固定4段階構成

```
Overview → Prerequisites → Usage → Troubleshooting
```

| セクション | 目的 |
|-----------|------|
| **Overview** | ガイドの目的と対象読者 |
| **Prerequisites** | 必要な環境・知識・ツール |
| **Usage** | ステップバイステップの手順 |
| **Troubleshooting** | よくある問題と対処法 |

## 変更履歴の運用

- **細かい修正**: git に委ねる。メタデータの `Updated:` 日付のみ更新
- **メジャー変更**: Changelog セクションに記録（Supersedes レベルの大きな改版のみ）

```markdown
## Changelog
- 2026-03-10: v2 — Supersedes VP-SPEC-000。要件ID体系を刷新
```

## テンプレート

### spec テンプレート

```markdown
# {PRJ}-SPEC-NNN: タイトル

> **Status**: Draft
> **Author**: @username
> **Created**: YYYY-MM-DD
> **Updated**: YYYY-MM-DD

---

## Abstract

（1-2文の要約）

## Motivation

（なぜ必要か。解決したい課題や背景）

## Scope

### In Scope
- ...

### Out of Scope
- ...

## Requirements

### REQ-{NAME}-001: 要件タイトル

説明文。

**Acceptance Criteria:**
- [ ] 基準1
- [ ] 基準2

### REQ-{NAME}-002: 要件タイトル

...

## Changelog
（メジャー変更時のみ。細かい修正は git に委ねる）

## References
- {PRJ}-DESIGN-NNN — 対応する設計書
```

### design テンプレート

```markdown
# {PRJ}-DESIGN-NNN: タイトル

> **Status**: Draft
> **Author**: @username
> **Created**: YYYY-MM-DD
> **Updated**: YYYY-MM-DD
> **Implements**: {PRJ}-SPEC-NNN

---

## Abstract

（設計の概要。どの Spec のどの要件を実装するか）

## Architecture

（コンポーネント構成。Mermaid 図を最低1つ含めること）

\`\`\`mermaid
flowchart LR
    A[Component A] --> B[Component B]
    B --> C[Component C]
\`\`\`

## Data Model

（データ構造・型定義）

## Implementation

### D1: セクションタイトル

...

### D2: セクションタイトル

...

## Changelog
（メジャー変更時のみ）

## References
- {PRJ}-SPEC-NNN — 対応する仕様書
```

### guide テンプレート

```markdown
# {PRJ}-GUIDE-NNN: タイトル

> **Status**: Draft
> **Author**: @username
> **Created**: YYYY-MM-DD
> **Updated**: YYYY-MM-DD
> **Supersedes**: {PRJ}-GUIDE-NNN（該当時のみ）

---

## Overview

（ガイドの目的と対象読者）

## Prerequisites

- 必要な環境
- 必要な知識
- 必要なツール

## Usage

### Step 1: タイトル

手順の説明。

\`\`\`bash
# コマンド例
\`\`\`

### Step 2: タイトル

...

## Troubleshooting

### 問題: タイトル

**症状**: ...
**原因**: ...
**解決策**: ...

## Changelog
（メジャー変更時のみ）
```

## ワークフロー

### 新機能追加時

1. `docs/spec/NN-feature-name.md` 作成（仕様書）
2. `docs/design/NN-feature-name.md` 作成（設計書）
3. Creo Memories に設計判断の経緯を記録（`category: "design-decision"`）
4. GitHub Issue でタスク化
5. 実装開始
6. 実装完了後、docs/ のドキュメントを更新

### 既存機能修正時

1. `docs/spec/` で確定仕様を確認
2. Creo Memories で経緯を検索（`search({ query: "..." })`）
3. 変更が設計に影響する場合、docs/ のドキュメントを更新
4. 実装

## Claudeへの指示

### 設計思想

→ chronista-style ルートの「設計哲学: Simplicity & Straightforward」に従う。
SDG ドキュメント自体もこの原則に基づく: 必要な情報だけ、冗長さを排除、4段階の直線的構成。

### コード変更時の必須手順

1. `docs/spec/` で確定仕様を確認
2. Creo Memories で設計判断の経緯を検索
3. `docs/design/` で設計書を確認
4. コード変更を実施
5. `docs/` のドキュメントとの乖離をチェック
6. 乖離があればドキュメントを更新
7. 重要な設計判断があれば Creo Memories に経緯を記録

### Mermaid 図の活用

Design の Architecture セクションには **最低1つの Mermaid 図を必須** とする。図の種類は自由。

#### 利用可能な Mermaid 図の種類

| 種類 | 構文 | 用途 |
|------|------|------|
| **Flowchart** | `flowchart TD` | 処理フロー、コンポーネント構成 |
| **Sequence Diagram** | `sequenceDiagram` | API 呼び出し、コンポーネント間通信 |
| **Class Diagram** | `classDiagram` | データモデル、型の関係性 |
| **State Diagram** | `stateDiagram-v2` | 状態遷移、ライフサイクル |
| **ER Diagram** | `erDiagram` | DB 設計、リレーション |
| **C4 Context** | `C4Context` | システムと外部アクターの関係（L1） |
| **C4 Container** | `C4Container` | システム内コンテナ構成（L2） |
| **C4 Component** | `C4Component` | コンテナ内コンポーネント（L3） |
| **C4 Dynamic** | `C4Dynamic` | C4 + シーケンス図風（動的フロー） |
| **C4 Deployment** | `C4Deployment` | デプロイ構成 |
| **Gantt** | `gantt` | スケジュール、タイムライン |
| **Pie Chart** | `pie` | 割合・分布 |
| **Gitgraph** | `gitGraph` | ブランチ戦略 |
| **Mindmap** | `mindmap` | アイデア整理、概念マップ |
| **Timeline** | `timeline` | 時系列イベント |
| **Sankey** | `sankey-beta` | フロー量の可視化 |
| **Block Diagram** | `block-beta` | ブロック構成図 |
| **Quadrant Chart** | `quadrantChart` | 2軸マトリクス（優先度評価等） |
| **XY Chart** | `xychart-beta` | 折れ線・棒グラフ |
| **Packet** | `packet-beta` | ネットワークパケット構造 |
| **Architecture** | `architecture-beta` | クラウド構成図 |
| **Kanban** | `kanban` | カンバンボード |

#### spec での推奨図
- **Flowchart**: 処理の流れ、ユーザー操作フロー
- **State Diagram**: ステートマシン、ライフサイクル
- **Mindmap**: コンセプト整理

#### design での推奨図
- **Flowchart / C4**: アーキテクチャ全体像
- **Class Diagram / ER Diagram**: データモデルの関係性
- **Sequence Diagram**: コンポーネント間の相互作用

### 禁止事項

- spec を確認せずにコード変更
- design の関連ドキュメントを確認せずに設計変更
- ドキュメント更新を忘れる
- 実装とドキュメントの不一致を許容

### Living Documentation原則

> **ドキュメントは死んだテキストではなく、生きたコードベースの鏡である**

- ドキュメントとコードは常に同期
- 不一致は技術的負債（バグ）として扱う
- AIエージェントが信頼して活用できる生きたメモリーとして機能する

## 関連リファレンス

- [Living Documentation原則](reference/living-documentation.md) - ドキュメントとコードの同期管理の詳細

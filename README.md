# Chronista Style Plugin

Chronistaとしての開発ワークフローを支えるClaude Codeプラグイン。ヒアリングファースト開発、Living Documentation、4つの規律スキルを統合。

> **バージョン**: プラグイン本体は `.claude-plugin/plugin.json` を、各スキルは個別の `SKILL.md` frontmatter を参照。履歴は [CHANGELOG.md](./CHANGELOG.md) に記録。

## インストール

```bash
/install chronista-club/claude-plugin-chronista-style
```

## スキル一覧

| スキル | 種別 | 説明 |
|--------|------|------|
| `chronista-style` | コア | 全スキルを統合するルートスキル。起動ルール、優先順序、基本方針を定義 |
| `codeflow` | プロセス（柔軟） | ヒアリングファーストで要件を明確化し、SDG で仕様・設計を記録する開発フロー |
| `route` | プロセス（柔軟） | Issue からゴールへの最適な path を探索し、最小コストで到達する |
| `parallel-dev` | プロセス（柔軟） | 並列開発の道具選び。「隔離・出荷」2 層モデルで worktree / VP lane / stacked PR を判断 |
| `spec-design-guide` | 実装（柔軟） | 仕様（What & Why）と設計（How）を Living Documentation 原則で管理 |
| `tdd` | 規律（厳守） | テストファーストで実装する RED-GREEN-REFACTOR サイクル |
| `systematic-debugging` | 規律（厳守） | 根本原因を特定してから修正する 4 ステップデバッグ |
| `verification` | 規律（厳守） | 証拠なき完了宣言を防ぐ。検証コマンド実行 → 出力確認 → 主張 |
| `code-review` | 実装（柔軟） | 技術的正直さを最優先するレビュー規律。YAGNI チェック付き |
| `council` | AI 協働 | 4 voice の合議で意思決定。多義的なトレードオフや go/no-go 判断に |
| `santa-method` | AI 協働 | 多 agent 敵対的検証。独立した 2 reviewer が両方 PASS するまで出荷しない |
| `agent-harness` | AI 協働 | AI agent の action space / observation / recovery / context budget を設計 |
| `agent-introspection` | AI 協働 | agent 自身の failure に対する構造化 self-debug |

### スキルタイプ


- **規律（厳守）**: `tdd`, `systematic-debugging`, `verification` -- 手順を正確に守る。省略・合理化は禁止
- **柔軟**: `codeflow`, `route`, `parallel-dev`, `spec-design-guide`, `code-review` -- 原則をコンテキストに合わせて適用
- **AI 協働**: `council`, `santa-method`, `agent-harness`, `agent-introspection` -- 複数 agent での意思決定・検証・設計

### 起動タイミング

| スキル | いつ発動するか |
|--------|----------------|
| `codeflow` | 新機能開発、設計判断が必要な時 |
| `tdd` | 機能実装・バグ修正の前（テストファースト） |
| `systematic-debugging` | バグ・テスト失敗・予期しない挙動に遭遇した時 |
| `verification` | 完了宣言・コミット・PR作成の前 |
| `code-review` | 主要機能完了後、マージ前、レビュー受信時 |
| `spec-design-guide` | コード変更・ドキュメント更新時 |

## コマンド

| コマンド | 説明 |
|----------|------|
| `/codeflow` | ヒアリングファースト開発セッションを開始 |
| `/hearing` | 構造化されたヒアリング（Q&A）セッションを開始 |
| `/sdg` | 仕様・設計ドキュメントの作成・更新 |
| `/route` | Issue からゴールへの最適な path を探索 |
| `/dashboard` | 全プロジェクトの進行中タスクを VP Canvas に一覧表示 |
| `/release` | バージョン bump、CHANGELOG 更新、タグ作成によるリリース実行 |

## Codeflow フロー概要

```
Discovery（調査）
    ↓
Second Opinion（Gemini等・任意）
    ↓
Discussion（方向性議論）
    ↓
Hearing（質問で詳細確認）
    ↓
SDG + Bite-Sized Tasks（仕様・設計・タスク分割）
    ↓
Branch & PR（main直コミット禁止）
    ↓
Implementation（TDDスキルに従う）
    ↓
Release（条件付き）
    ↓
Learning（creo-memoriesに記録）
```

各ステップは**名前で参照**する（番号は使わない）。詳細は `codeflow` スキルを参照。

## 関連プラグイン

| プラグイン | 説明 |
|-----------|------|
| [creo-memories](https://github.com/chronista-club/claude-plugin-creo-memories) | 永続記憶システム（MCP Server） |

## ライセンス

MIT

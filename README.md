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
| `codeflow` | プロセス（柔軟） | ヒアリングファーストで要件を明確化し、SDGで仕様・設計を記録する開発フロー |
| `spec-design-guide` | 実装（柔軟） | 仕様（What & Why）と設計（How）をLiving Documentation原則で管理 |
| `tdd` | 規律（厳守） | テストファーストで実装するRED-GREEN-REFACTORサイクル |
| `systematic-debugging` | 規律（厳守） | 根本原因を特定してから修正する4ステップデバッグ |
| `verification` | 規律（厳守） | 証拠なき完了宣言を防ぐ。検証コマンド実行→出力確認→主張 |
| `code-review` | 実装（柔軟） | 技術的正直さを最優先するレビュー規律。YAGNI チェック付き |

### スキルタイプ

- **規律（厳守）**: `tdd`, `systematic-debugging`, `verification` -- 手順を正確に守る。省略・合理化は禁止
- **柔軟**: `codeflow`, `spec-design-guide`, `code-review` -- 原則をコンテキストに合わせて適用

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
| `/release` | バージョンbump、CHANGELOG更新、タグ作成によるリリース実行 |

## Codeflow フロー概要

```
Discovery（調査）
    ↓
Second Opinion（Gemini等・任意）
    ↓
Discussion（方向性議論）
    ↓
Hearing（一問一答で詳細確認）
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
| [fleetflow](https://github.com/chronista-club/claude-plugin-fleetflow) | KDLベースのコンテナオーケストレーション（MCP Server） |

## ライセンス

MIT

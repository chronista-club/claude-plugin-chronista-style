---
description: プロジェクト形式を自動検出してバージョンbump・CHANGELOG更新・タグ作成を実行
arguments:
  - name: version
    description: リリースバージョン（例: 0.3.0, 1.0.0）。省略時は対話で決定
    required: false
---

# Release

プロジェクトのリリースを実行する。**対象ファイルを自動検出**し、Rust / Claude Code プラグイン / npm のいずれにも対応する。

## 手順

各ステップで結果をユーザーに報告すること。

### Step 1: 対象形式の検出

リポジトリルートを調べて、以下の優先順で「リリース対象」を判別する:

| 検出 | 形式 | バージョン SSoT |
|------|------|----------------|
| `.claude-plugin/marketplace.json` が存在 | **Claude Code プラグイン** | `plugins[].version`（該当 plugin name を特定） |
| `Cargo.toml` が存在（workspace ルート） | **Rust** | `package.version` または `workspace.package.version` |
| `package.json` が存在 | **npm** | `version` フィールド |

複数検出された場合は `AskUserQuestion` で「どの形式でリリースしますか？」を尋ねる。

### Step 2: 現状把握

1. `git tag --sort=-creatordate | head -5` で最新タグを確認
2. 前回リリース以降の commit を取得（`git log <last-tag>..HEAD --oneline`、タグ無しなら `git log --oneline -30`）
3. 対象ファイルの現バージョンを読み取る
4. 既存 `CHANGELOG.md` を確認（無ければ新規作成予定として扱う）

### Step 3: バージョン決定

引数 `$ARGUMENTS` にバージョンが指定されていればそれを使う。無ければ commit 内容を分析しセマンティックバージョニングで提案:

- **MAJOR**: 破壊的変更（`BREAKING:` プレフィックス、大規模リファクタ）
- **MINOR**: 新機能追加（`feat:` コミット）
- **PATCH**: バグ修正のみ（`fix:` / `chore:` のみ）

`AskUserQuestion` で提案をユーザーに確認してから確定する。

### Step 4: SKILL.md の version bump 範囲確認（プラグイン形式のみ）

Claude Code プラグイン形式の場合、**`AskUserQuestion` で SKILL.md の version も bump するかを尋ねる**:

- **all** — 全スキル一律 patch bump
- **selective** — 変更があったスキルのみ対話で選択
- **none** — skill 側は触らない（プラグイン本体のみ bump）

### Step 5: CHANGELOG.md 生成・更新

Keep a Changelog 形式で [X.Y.Z] エントリを追加する。既存 `CHANGELOG.md` がなければヘッダ付きで新規作成。

カテゴリ:
- **Added** — 新機能（`feat:` コミット）
- **Changed** — 既存機能の変更（`refactor:` / `change:` / `feat!:` コミット）
- **Deprecated** — 非推奨化
- **Removed** — 削除された機能
- **Fixed** — バグ修正（`fix:` コミット）
- **Security** — セキュリティ修正

日付は ISO 8601（YYYY-MM-DD）。今日の日付を `$CURRENT_DATE` 環境変数または `date +%Y-%m-%d` で取得。

### Step 6: バージョン bump

検出された形式に応じて、対象ファイルを更新:

- **プラグイン**: `.claude-plugin/marketplace.json` の該当 `plugins[].version` を書き換え
- **Rust**: `Cargo.toml` の `version` を書き換え（workspace ルートなら `workspace.package.version`）
- **npm**: `package.json` の `version` を書き換え

さらに Step 4 で選択された SKILL の `version:` も bump（プラグイン形式で選択された場合）。

### Step 7: コミット & タグ

```bash
git add -A
git commit -m "release: vX.Y.Z — <主要変更の1行要約>"
git tag vX.Y.Z
```

**タグは lightweight tag**（`-a` は使わない）。コミットメッセージは日本語でも OK、ただしプレフィックスは `release: vX.Y.Z — ` で統一。

### Step 8: 確認

- `git log --oneline -3` で結果を表示
- `git tag -l 'v*' --sort=-creatordate | head -5` でタグ一覧を表示
- **push は自動で行わない**。`AskUserQuestion` で「push しますか？」を尋ねる

## 注意事項

- crates.io / npm registry への publish は自動では行わない（`cargo publish` / `npm publish` はユーザーが手動）
- pre-release タグ（`-alpha`, `-beta`, `-rc`）もサポートする
- タグは **lightweight tag** を使用する
- `marketplace.json` に複数プラグインがある場合、bump 対象を `AskUserQuestion` で選ばせる

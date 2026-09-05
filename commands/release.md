---
description: プロジェクト形式を自動検出してバージョンbump・CHANGELOG更新・タグ作成を実行
argument-hint: "[version]"
---

# Release

プロジェクトのリリースを実行する。**対象ファイルを自動検出**し、Rust / Claude Code プラグイン / npm のいずれにも対応する。

## 手順

各ステップで結果をユーザーに報告すること。

### Step 1: 対象形式の検出

リポジトリルートを調べて、以下の優先順で「リリース対象」を判別する:

| 検出 | 形式 | バージョン SSoT |
|------|------|----------------|
| `.claude-plugin/plugin.json` が存在 | **Claude Code プラグイン** | `version` フィールド |
| `.claude-plugin/marketplace.json` が存在（marketplace repo） | **Claude Code marketplace** | `plugins[].version`（該当 plugin name を特定） |
| `Cargo.toml` が存在（workspace ルート） | **Rust** | `package.version` または `workspace.package.version` |
| `package.json` が存在 | **npm** | `version` フィールド |

プラグイン単体の repo は `plugin.json` のみを持つ（本 repo がこれ）。両方ある場合は `plugin.json` を本体の正とし、`marketplace.json` は配布メタとして追従させる。

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

### Step 4: SKILL.md の version 同期（プラグイン形式のみ）

`git diff <last-tag>..HEAD --name-only -- 'skills/*/SKILL.md'` で変更のあったスキルを列挙し、frontmatter の `version:` が既に上がっているか確認する。上がっていないものがあれば patch bump の提案に含め、Step 3 の版の確認と一緒に 1 回で確定する。別途は聞かない。

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

- **プラグイン**: `.claude-plugin/plugin.json` の `version` を書き換え（marketplace repo の場合は `.claude-plugin/marketplace.json` の該当 `plugins[].version`）
- **Rust**: `Cargo.toml` の `version` を書き換え（workspace ルートなら `workspace.package.version`）
- **npm**: `package.json` の `version` を書き換え

さらに Step 4 で確定した SKILL の `version:` も bump（プラグイン形式のみ）。

### Step 7: コミット & タグ

```bash
git add -A
git commit -m "release: vX.Y.Z — <主要変更の1行要約>"
git tag vX.Y.Z
```

**タグは lightweight tag**（`-a` は使わない）。コミットメッセージは日本語でも OK、ただしプレフィックスは `release: vX.Y.Z — ` で統一。

#### 🚦 Tag Verify Gate（必須）

tag 作成**直後**に必ず以下を実行し、tag が実体として存在するか検証する:

```bash
git tag -l vX.Y.Z          # 出力が "vX.Y.Z" であること
git rev-parse vX.Y.Z       # commit SHA が返ること
```

**失敗時**: `git tag` が silently skip された可能性（既存 tag 衝突等）。即座に原因を特定し、ユーザーに報告して指示を仰ぐ。**Step 8 に進んではいけない**。

#### 🔍 過去ドリフト検出（推奨）

`git log --oneline | grep -E '^[a-f0-9]+ release: v'` で「release: vX.Y.Z」commit を列挙し、対応する tag が全て存在するか確認:

```bash
# 各 release commit に対応する tag があるか
for v in $(git log --oneline | grep -oE 'release: v[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}'); do
  git rev-parse "$v" >/dev/null 2>&1 || echo "MISSING TAG: $v"
done
```

欠損 tag を検出したら、`AskUserQuestion` で「過去 commit に後付け tag するか？」を尋ねて修復する。

### Step 8: 確認

- `git log --oneline -3` で結果を表示
- `git tag -l 'v*' --sort=-creatordate | head -5` でタグ一覧を表示
- **push は自動で行わない**。`AskUserQuestion` で「push しますか？」を尋ねる

## 注意事項

- crates.io / npm registry への publish は自動では行わない（`cargo publish` / `npm publish` はユーザーが手動）
- pre-release タグ（`-alpha`, `-beta`, `-rc`）もサポートする
- タグは **lightweight tag** を使用する
- `marketplace.json` に複数プラグインがある場合、bump 対象を `AskUserQuestion` で選ばせる

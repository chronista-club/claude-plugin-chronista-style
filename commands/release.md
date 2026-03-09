---
description: バージョンを上げてリリースする（CHANGELOG更新、バージョンbump、タグ作成）
arguments:
  - name: version
    description: リリースバージョン（例: 0.3.0, 1.0.0）。省略時は対話で決定
    required: false
---

# Release

プロジェクトのリリースを実行する。

## 手順

以下のステップを順番に実行すること。各ステップで結果をユーザーに報告する。

### Step 1: 現状把握

1. `git log` で前回リリースタグ以降のコミットを取得
2. `git tag --sort=-creatordate` で最新のタグを確認
3. ワークスペースのバージョン（`Cargo.toml` の `version`）を確認
4. CHANGELOG.md の最新エントリを確認

### Step 2: バージョン決定

引数 `$ARGUMENTS` にバージョンが指定されていればそれを使う。
指定がなければ、コミット内容を分析してセマンティックバージョニングに基づき提案する:

- **MAJOR**: 破壊的変更がある場合
- **MINOR**: 新機能追加がある場合
- **PATCH**: バグ修正のみの場合

ユーザーに確認を取ってからバージョンを確定する。

### Step 3: CHANGELOG.md 更新

前回リリース以降のコミットを分析し、Keep a Changelog 形式で CHANGELOG.md にエントリを追加する。

カテゴリ:
- **追加**: 新機能
- **変更**: 既存機能の変更
- **削除**: 削除された機能
- **修正**: バグ修正

日付は今日の日付（ISO 8601 形式）を使用する。

### Step 4: バージョン bump

プロジェクトのバージョン管理ファイルを更新する:

- **Rust (Cargo.toml)**: `version = "X.Y.Z"` をワークスペースルートで更新
- 他の設定ファイルがあれば同様に更新

### Step 5: コミット & タグ

```
git add -A
git commit -m "release: vX.Y.Z — 簡潔な説明"
git tag vX.Y.Z
```

コミットメッセージのフォーマット: `release: vX.Y.Z — 主要な変更の要約`

### Step 6: 確認

- `git log --oneline -3` で結果を表示
- `git tag -l 'v*' --sort=-creatordate | head -5` でタグを表示
- push するかどうかユーザーに確認（自動では push しない）

## 注意事項

- crates.io への publish は自動では行わない（`cargo publish` はユーザーが手動で実行）
- pre-release タグ（`-alpha`, `-beta`, `-rc`）もサポートする
- タグは lightweight tag を使用する（annotated tag ではない）

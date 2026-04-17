# Changelog

本プラグインの主要な変更を [Keep a Changelog](https://keepachangelog.com/ja/1.1.0/) に沿って記録する。
バージョニングは [Semantic Versioning](https://semver.org/lang/ja/) に準拠する。

プラグイン全体の version は `.claude-plugin/marketplace.json` を正とする（SSoT）。
各スキル個別の version は該当 `SKILL.md` の frontmatter に記載。

## [Unreleased]

## [2.1.0] - 2026-04-17

### Added
- **新スキル `route`** (v1.0.0): Issue からゴールへの最適 path を探索する経路探索スキル
  - 6 フェーズ: Survey → Plot → Compare → Choose → 🚦 HARD GATE → Travel → Log
  - ケーススタディ: fleetstage FSC-22 (2026-04-17, 半日想定 → 45 分で完走)
  - 「グルーブを忘れない」姿勢セクション（codeflow の姉妹節）
  - 発火の目安・アンチパターン集付き
- **新コマンド `/route`** (`commands/route.md`): Route スキルのエントリポイント
  - Issue ID を引数で受け、Survey〜Choose まで実行して HARD GATE で承認を待つ

## [2.0.1] - 2026-04-17

### Added
- `hooks/session-start.sh` に **Atlas 自動認識フロー** を追加。ディレクトリ名ベース（A）を優先し、git remote URL（C）をフォールバックとするハイブリッド検出
- hook 出力で Claude に「優先候補 A で exact match → フォールバック C → AskUserQuestion」の順序を明示

### Fixed
- hook スクリプトで BSD sed の `+?` 非互換エラーを解消（macOS 対応）

## [2.0.0] - 2026-04-17

大規模リファクタ。**破壊的変更を含む**。

### Added
- `CHANGELOG.md` を初回作成（Keep a Changelog 形式）
- `hooks/hooks.json` + `hooks/session-start.sh` 追加。SessionStart で git コンテキストを注入し、creo-memories 検索を Claude に促す
- 5 スキル（`spec-design-guide` / `tdd` / `systematic-debugging` / `verification` / `code-review`）の SKILL.md に `version:` フロントマター（初期 `1.0.0`）を追加

### Changed
- **バージョン SSoT を `marketplace.json` に一本化**（`.claude-plugin/plugin.json` は廃止）
- **Phase 番号を全廃**、ステップ名で管理に移行（Discovery → Discussion → Hearing → SDG → Branch & PR → Implementation → Release → Learning）
- `commands/codeflow.md` `hearing.md` `sdg.md` を **hearing 起動装置型** に再構築。まず `AskUserQuestion` で意図をキャプチャしてから進める
- `commands/release.md` を汎用化。`marketplace.json` / `Cargo.toml` / `package.json` を自動検出して version bump + CHANGELOG 更新 + git tag まで対応
- `chronista-style` SKILL.md を `3.4.0` → `4.0.0`（Phase 構造の破壊的変更）
- `codeflow` SKILL.md を `1.8.0` → `2.0.0`（Phase → step name への破壊的変更）
- `README.md` の version 3.0.0 表記を削除し、SSoT への参照に差し替え

### Removed
- `.claude-plugin/plugin.json`（marketplace.json 一本化のため廃止）
- `.claude-plugin/skills.txt`（Claude Code 仕様外のレガシー残骸）

### Fixed
- plugin.json / marketplace.json / SKILL.md / README.md のバージョン表記が 4 箇所でズレていた問題を根本解決

## [1.1.0] - 2026-02-XX（遡及記録）

fleetflow を別プラグインとして marketplace に分離。chronista-style 本体は `1.1.0`。

（commit: `fdddbb6 refactor: fleetflowを別プラグインに分離`）

## [1.0.0] - 2025-12-XX（遡及記録・推定）

初回マーケットプレイス対応。

（commit: `bee3ed1 feat: マーケットプレイス対応を追加`）

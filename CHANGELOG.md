# Changelog

本プラグインの主要な変更を [Keep a Changelog](https://keepachangelog.com/ja/1.1.0/) に沿って記録する。
バージョニングは [Semantic Versioning](https://semver.org/lang/ja/) に準拠する。

プラグイン全体の version は `.claude-plugin/marketplace.json` を正とする（SSoT）。
各スキル個別の version は該当 `SKILL.md` の frontmatter に記載。

## [Unreleased]

## [0.25.0] - 2026-07-04

### Added
- **Stop hook `fabrication-tripwire.sh`** (`hooks/`): ターン終了時に assistant の**最終メッセージ**の「ツール出力の形をした文字列」を検出し、同じターンの本物の tool_result に裏付けが無ければ差し戻す(ツール結果の捏造を外側から止める関門)。fail-open。意図的な引用は明示トークン `TRIPWIRE-ACK` を**単独行**で置いて通す(文中の言及では解除されない)。`hooks/hooks.json` に Stop エントリ(`${CLAUDE_PLUGIN_ROOT}` 参照)を追加
  - 設計は実 transcript で検証済み: ターン境界 = 最後の実 user プロンプト(`content` が string の entry。tool_result entry や `Stop hook feedback:` 注入は境界にしない — 後者を境界にすると block 後の書き直しで同ターン前半の tool_result が孤立し偽陽性 loop になる)
  - 実 harness で live-fire 済み(意図的な捏造行を Stop で block → 差し戻し理由の提示を実観測)。synthetic fixture 9 ケース(block 5 / allow 4)も PASS

### Changed
- `verification` SKILL.md を `1.0.1` → `1.1.0`: 「捏造 — 検証不足の極限形」セクションを追加。ツール結果の捏造(実行せず出力を地の文に書く / 呼んでいない第二意見をでっち上げる / 予測を観測として混ぜる)を「証拠なき完了宣言」の極限形として明文化。認知メカニズム(予測と観測の混同・完了イメージへの引力・自問の脆さ)と、意志ベースの規律に加えて**構造的関門**(Stop hook `fabrication-tripwire.sh` + `TRIPWIRE-ACK` escape hatch)を記載

## [0.24.3] - 2026-05-17

### Added
- `bin/setup-windows`: Windows (Git Bash + winget) 用の開発環境セットアップスクリプト

### Changed
- `codeflow` SKILL.md を `2.0.1` → `2.1.0`: Linear 連携記述を memory-native (memory-as-issue) に更新。2026-04-23 pivot (Linear → creo-memories) を反映し、Cross-Project Handoff subsection を追加 (PR #8)
- `bin/setup` を macOS 専用化し OS 判定を追加 (Windows は `bin/setup-windows` に委譲)。パッケージ群を BUILD_SUPPORT / LSP / LINT / AI / cask / font 等に再編・拡張

## [0.24.2] - 2026-05-04

### Added
- **新スキル `size-stepper`** (v1.0.0): design token を 「演奏できる Live Token」 として扱う 4 層 architecture
  - TS class (SizeStepper) + Solid signal + CSS scope mirror + MIDI 2.0 connector
  - namespace 階層 (UI → BUTTON / HEADER) + parent 継承 + lock per-key
  - adjacent ceiling / per-key precision / bounds override / Export to clipboard
  - Korg Keystage 1 row binding (CC 0-7 = UI 5 step + BUTTON.m + HEADER.{m,l})
  - 「最終 const 化」 lifecycle (探索 → 確定候補 → 焼き戻し → 運用) を仕組み化
  - origin: fleetstage-hq commits 87207917 / 735b5188 / 97e98a24

## [0.24.1] - 2026-05-02

### Changed
- Skill tree refactor: 12 skill dir (agent-harness, agent-introspection, chronista-style, code-review, codeflow, council, route, santa-method, spec-design-guide, systematic-debugging, tdd, verification) を root から `skills/` 下に移動 (公式 spec 準拠)

### Removed
- Redundant inner `.claude-plugin/marketplace.json` (self-referential で冗長、 plugin.json のみに統一)


## [2.4.0] - 2026-05-01

### Added
- **新スキル `council`** (v1.0.0): 4-voice 合議で意思決定
  - Architect / Skeptic / Pragmatist / Critic の 4 視点で trade-off を可視化
  - Anti-anchoring mechanism: subagent を fresh context で召集 (会話履歴を渡さない)
  - 元 ECC `council` から chronista 適合 fork (memory-first 連携、 VP 文脈の例追加)
- **新スキル `santa-method`** (v1.0.0): 多 agent 敵対的検証 (adversarial verification)
  - Generate → Dual Review → Verdict Gate → Fix Until Nice の 4 フェーズ
  - 両者 PASS 必須、 各 round fresh agent (前 round の anchoring 防止)
  - 元 Ronald Skelton (RapportScore.ai) から chronista 適合 fork
- **新スキル `agent-harness`** (v1.0.0): AI agent harness 設計
  - Action space / Observation / Recovery / Context budget の 4 軸
  - VP Stand Actor Framework / ccws worker autonomous mode と整合
- **新スキル `agent-introspection`** (v1.0.0): AI agent 自身の failure self-debug
  - Capture → Diagnose → Contain → Report の 4 フェーズ
  - `systematic-debugging` (コード/システムバグ) と領域分離 (こちらは agent loop / drift / max tool call)

### Changed
- `chronista-style` SKILL.md (v4.3.0 → v4.4.0): スキル構成に 4 新 skill + 既存 `route` を register

### Notes
- 4 新 skill は **AI 協働カテゴリ** として一塊で機能: council (decide) → santa-method (verify) → agent-harness (design) → agent-introspection (debug)
- 元 ECC plugin (everything-claude-code) の同名 skill から chronista 適合 fork。 ECC plugin 全体は disable しつつ、 必要 skill のみ chronista 側に統合する軽量 cherry-pick 戦略
- 各 skill は memory-first 連携セクション (creo-memories integration) を持ち、 VP 文脈の具体例 (D11 / Stand × Pane × Lane / ccws worker / Mailbox) を含む

## [2.3.0] - 2026-04-25

### Changed
- **`code-review` SKILL.md (1.0.1 → 2.0.0)** — 規律スキルから「実行手法 + 規律 + 受信」の統合スキルに刷新 (BREAKING)
  - **§A. レビュアー (主体)** 新設 — Quick / Standard / Deep の 3 mode、`team-bucciarati` Stand 連携 (Aerosmith / Moody Blues / Purple Haze / Spice Girl / Gold Experience)
  - **§B. 著者 (受信)** — 旧 SKILL.md の Part 1, 2 を吸収 (依頼 / 受信 / 禁止レスポンス / YAGNI / 反論)
  - **§C. 定期実行** 新設 — `/schedule` 経由で週次 / 月次 Deep review を回す手順
  - **§D. 共通規律** — performative agreement 禁止、信頼度スコアリング 75+
  - 移行: 既存ユーザは規律部分 (旧 Part 1, 2) は §B + §D に再配置されたが内容は同じ
- `reference/` 配下に詳細手順を分離
  - `modes.md` — Quick / Standard / Deep の詳細フロー
  - `stand-mapping.md` — Pass 1〜8 の観点と Stand 対応表
  - `periodic-setup.md` — `/schedule` 連携手順
  - `examples.md` — 実例 (Quick / Deep / 定期 / 受信側 / 反論)

### Why
- 既存 `code-review` は「規律」のみ、「実行手法」のスキルが穴だった
- multi-pass 手法を別 skill にする案も検討したが、ユーザ feedback「skill 増やしたくない、定期的にやりたいがスコープは可変」を受けて 1 skill に統合
- Hybrid Z (parallel + iterative) で scope に応じて Quick から Deep までシームレスに切替可能

## [2.2.0] - 2026-04-20

### Added
- `chronista-style` SKILL.md (v4.3.0) に **推奨スタイル: 言語と表現** セクション追加
  - **Python が出てきたら、まず Ruby で考える**: スクリプト・CLI・小さなツール・DSL では Ruby を第一候補とし、Python を選ぶ場合も Ruby 案を並べてユーザーに共有してから決める（ML / 数値計算等の Python エコシステム必須ケースは例外として明記）
  - **JSON が出てきたら、まず KDL で考える**: 設定・データ表現で JSON が登場する文脈では KDL を第一候補とし、JSON を選ぶ場合も KDL 表現を並べてユーザーに共有してから決める

### Changed
- 全スキル SKILL.md を patch bump（chronista-style 経由で参照される土台スキルとして整合性を確保）
  - `codeflow` 2.0.0 → 2.0.1
  - `tdd` / `systematic-debugging` / `verification` / `code-review` / `spec-design-guide` / `route` 1.0.0 → 1.0.1

### Fixed
- v2.1.0 タグ欠損を修復（過去 commit `5d69392` に lightweight tag を後付け）

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

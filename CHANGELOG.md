# Changelog

本プラグインの主要な変更を [Keep a Changelog](https://keepachangelog.com/ja/1.1.0/) に沿って記録する。
バージョニングは [Semantic Versioning](https://semver.org/lang/ja/) に準拠する。

プラグイン全体の version は `.claude-plugin/plugin.json` を正とする（SSoT）。
各スキル個別の version は該当 `SKILL.md` の frontmatter に記載。

## [Unreleased]

### Changed
- **Fable 5.1 harness 注入文との衝突解消**（mako 裁定 2026-09-03「衝突は、自分もやだな。解消したいよね」）。Claude Code 本体が [Claude Fable 5.1 のプロンプティング](https://platform.claude.com/docs/ja/build-with-claude/prompt-engineering/prompting-claude-fable-5-1) の推奨文（進捗更新 / バッチ化ナッジ / Delivering work / 自律実行）を原文のまま system prompt に注入していることを実測。同じ文言は足さず、逆向きの文言だけを本体の語彙で言い直した
  - `hooks/session-start.sh`: 規律エッセンス 4 行目「設計判断は短い方針提示 → GO」を「ユーザーが選ぶべき分岐があるときだけ短い方針提示 → GO。GO の後はその範囲を最後まで走り切る」に。本体の「可逆な作業は聞かずに進める」と綱引きしていた
  - `codeflow` `3.1.0` → `3.2.0`: 実装前の合意に「GO の後」を追加 — 合意した範囲は走り切る、質問は回答に依存しない部分を済ませてから進捗と一緒にターン末尾で
  - `hooks/fabrication-tripwire.sh`: 裏付けの tool_result を同一ターンから **transcript 全体**に拡張。本体が求める「単独で読める recap」が前ターンの観測結果を再掲すると false block していた（本セッションで実際に block されて再現）。「一度も produce されていない結果を止める」目的は保持。scratch test 3 ケース（cross-turn recap / 純粋な捏造 / 同一ターン裏付け）で RED → GREEN を観測
  - `verification` `1.2.0` → `1.2.1`: tripwire の説明を「同じセッション内の」に同期。`hooks/hooks.json` の description も同期

### Added
- `chronista-style` `5.2.0` → `5.3.0`: Issue-first に「作業中に見つけた対象外の問題は直さず spark 起票、最終報告で触れる」を追加。docs「follow-up として summary で報告せよ。Fable 5.1 は近くのコードを直したがる」の Chronista 版（follow-up の行き先 = creo-memories）。parallel-dev の「混ざったら `git add -p` で割る」は事後策で、事前策が無かった
- `tdd` `1.1.0` → `1.2.0`: 完了チェックリストにテストの**量**の目安（振る舞い 1 つに 1 本、隣接ファイルと同粒度、使い捨て確認スクリプトは残さない）。docs「Fable 5.1 は変更に見合う以上のテストファイルをコミットする。指示で大幅に減り成功率は不変」への対応

## [0.29.0] - 2026-09-01

### Added
- **セッション分析（29 プロジェクト・509MB の transcript）からの改善盛り込み**（mako 裁定 2026-09-01、全 4 項目採用）
  - `chronista-style` `5.1.0` → `5.2.0`: **North Star「強く美しい構造（Strong & Beautiful）」**を設計哲学の上位に新設し、強さ（変化と時間に耐える）と美しさ（読み手に一目で伝わる）を定義。Simplicity & Straightforward が両方を**同時に**生む技法であることを明文化し、判定基準「これは強く、かつ美しくするか？」と例（重複統合の Yes/No）を付す
  - `hooks/session-start.sh`: **規律エッセンスの常時注入** — 54 セッション中 chronista-style スキルの明示発動が 2 回のみという実測を受け、規律 3 スキル + 合意フローのエッセンス 4 行を additionalContext で常時届ける（スキル本文は従来どおり発動時のみ）
  - `verification` `1.1.0` → `1.2.0`: **ユーザー観測の層** — agent の green で閉じない変更（実機・実 UI・実環境）は「実機確認待ち」で止める。ladyland の実機検証ループ（「実機」言及 75 回）の明文化
  - `codeflow` `3.0.0` → `3.1.0`: **合意の粒度**を明文化 — 短い方針提示に「いいね」「進めて」の GO で走る（「進めて」49 回・「どう？」34 回の実リズムに整合）。Learning に**裁定の原文引用**ルールを追加

## [0.28.0] - 2026-09-01

### Removed
- **fleetstage 関連を全削除**（mako 裁定 2026-09-01「fleetstage はオミット仕様。関わるものは一旦全部削除」）
  - `skills/size-stepper/` — origin = fleetstage-hq。実コード（`~/repos/fleetstage/.../ui/`）が SSOT で、参照先なしでは再現不能
  - `skills/cross-build-image/` — origin = fleetstage Phase B-3。実行例・参考実装とも fleetstage-hq-api 依存（同梱 `scripts/build-and-push.sh` 含む）
  - `skills/route/` の FSC-22 ケーススタディと、`commands/route.md` の FSC 系引数例
- **ミニマム化 — 「プロダクト群を横断する共通の開発スタイル基盤」に絞る**（mako 裁定 2026-09-01）。スキル 15 → 8、コマンド 6 → 5
  - `skills/santa-method/` — **team-bucciarati へ移設**（多 agent 敵対的検証は agent team プラグインのドメイン。中身は無改変で移動、slim 化は team-b 側の棚卸しで行う）
  - `skills/code-review/` — 削除。汎用レビューは Claude Code 標準の `/code-review` が受け、Stand 観点別 dispatch の知識（`reference/stand-mapping.md`）は team-bucciarati へ移設
  - `skills/agent-harness/` / `skills/agent-introspection/` — 削除。発動場面が抽象的で、description のコンテキスト税が全スキル中最大級（計 470 字）だった
  - `skills/route/` + `commands/route.md` — 削除。Survey→Plot→Compare→Choose は codeflow の Discovery→Discussion と重複
  - `bin/setup` / `bin/setup-windows` は存置（コンテキスト税ゼロ、新マシン立ち上げと .mcp.json 復元 path として実用）

### Changed
- `council` `1.0.2` → `2.0.0`: 283 → 99 行に縮約。中核メカニズム（4 voice の役割、fresh subagent への文脈隔離 = anti-anchoring、Position 先行、Synthesize の bias guardrail、strongest dissent の可視化）だけを残し、The Iron Rule・NG パターン表・アンチパターン節・多 round 運用・クイックリファレンス・VP 固有の適用例を削除。santa-method（→ team-b）と `/code-review`（→ Claude Code 標準）への参照を新配置に同期
- `chronista-style` `5.0.0` → `5.1.0`: スキルツリーを 8 スキルに同期。発動テーブルの code-review 行を council 行に置換
- `README.md` / `plugin.json`: 冒頭にプラグインの存在意義を明文化 — 「Chronista のプロダクト群を横断する共通の開発スタイル基盤」（個別プロダクト名は列挙しない — 列挙は腐るため）

## [0.27.0] - 2026-09-01

### Removed
- **codeflow `reference/` 5 ファイル（計 3,969 行）を削除**（`codeflow` `2.1.1` → `3.0.0` の一部）: `claude-code-advanced-discoveries.md`（2025-11-18 時点の内部ツール調査）/ `claude-code-internal-tools.md` / `ask-user-question-tool.md` / `hearing-first.md` / `development-flow.md`。Claude Code 本体が保証するツール仕様のスナップショットはモデルと harness の進化で必ず腐り、古い仕様の注入はむしろ有害。現行モデル（Fable / Opus 世代）には手順の長大な例示も不要
- `chronista-style`: 廃止済み fleetflow プラグインのインフラ節・`openskills read` 参照 ×4・`gh issue create` ベースの旧タスク化フロー（memory-as-issue SSOT と矛盾）・発動テーブルのスキル非実在行（fleetflow / mise / Chrome DevTools）を削除。fleetflow CLI 本体は継続のため `.fleetflow/*.kdl` の変更検出行は温存
- `README.md`: 廃止済み fleetflow の関連プラグイン行を削除

### Changed
- **「モデルを型に嵌める拘束」を判断委任型に書き換え**（mako 裁定 2026-09-01「大胆に削る」— 作り込んだ harness / skill はモデル性能を落としやすい、Fable / Opus を信じる方向へ）
  - `chronista-style` `4.6.0` → `5.0.0`: The Iron Rule（1% でも該当なら発動・交渉不可）+ 合理化の罠テーブル → 「起動の基準」（該当判断はモデルに委ね、規律スキルのみ省略不可）。Ruby-first / KDL-first の「必ず比較案を共有」儀式 → 既定値の表明。creo-memories 節は Context Engine の自動注入を前提化し手動検索儀式を削除。一問一答の絶対化を解除（関連質問は束ねてよい、依存質問はラウンドを分ける）
  - `codeflow` → `3.0.0`: HARD GATE（設計承認なしにコードを書くな）→ 「実装前の合意」（設計判断を伴う変更のみ。明白な小修正は直進。判断軸 = ユーザーが選ぶべき分岐があるか）。Hearing の create_todo / complete_todo 儀式を AskUserQuestion 軸に簡素化
  - `route` `1.0.2` → `1.1.0` / `commands/route.md`: HARD GATE → **Confirm** フェーズに改称。path 選択のユーザー承認自体はスコープ判断として維持
  - `commands/hearing.md`: 質問ごとの todo 登録 → 一覧 → 一問一答ループを廃止し、論点抽出 → AskUserQuestion → 決定事項のみ記録に書き直し
  - `tdd` `1.0.1` → `1.1.0` / `systematic-debugging` → `1.0.2`: 「削除しろ。やり直せ」「資格はない」等の脅迫調を、規律の中身（失敗の観測・調査の完遂）を保ったまま行動指示に変換
  - `hooks/session-start.sh`: Atlas 探索プロトコル（list_atlas → search ×3 → 報告）を撤去し、git コンテキスト + Atlas 候補の提示に縮約（107 → 84 行）。creo-memories v3.0 Context Engine の自動注入と重複していた
  - `council` → `1.0.2` / `code-review` → `2.1.1` / `size-stepper` → `1.0.1`: 一問一答原則への cross-reference を新方針に同期
- `.gitignore`: VS Code Mermaid 拡張が自動生成する `.github/copilot-instructions.md` / `.github/instructions/` を無視対象に追加

## [0.26.0] - 2026-08-31

### Added
- **新スキル `parallel-dev`** (v0.2.0): 並列開発の道具選びを「**隔離・出荷**」の 2 層モデルで判断する規律スキル
  - **隔離**（テスト・ビルドが独立に走る）は worktree が解く — 小タスク = session worktree / 大タスク = VP lane
  - **出荷**（依存 PR の列車）は GitHub native stacked PR (`gh stack`) が解く — bottom merge で server-side cascading rebase
  - 「メイン作業中に別スコープの修正が混ざった」場合は手を止めず、コミット時に `git add -p` でハンク単位に割って別ブランチへ回す（混ざりを咎めず、後から割る）
  - 2026-08-28 に仮想ブランチによる「分流」層を廃止し 3 層 → 2 層へ移行。分流層は VP lane と役割が重複し実運用で出番がなかった
- `chronista-style` に **ブランチ運用（nightly trunk）** セクションを新設。開発 trunk を `nightly` とし、日々の PR は `--base nightly` で積む。リリース時に version bump して `nightly → main` を **merge commit** でマージし、main で tag を打つ（squash すると履歴が発散し次回リリースで全面コンフリクトするため）
  - 併せて **GitHub のデフォルトブランチは `main` のまま**にする理由を明記。プラグイン marketplace（`chronista-club/claude-plugins`）の source 定義に `ref` 指定が無く、**デフォルトブランチがそのまま配布元になる**ため、nightly をデフォルトにすると未リリース版が配布される

### Changed
- **Linear への依存を完全に除去** — 実運用で使われなくなったため、現行ガイダンスから存在ごとオミットした（`CHANGELOG.md` の歴史エントリは記録として温存）
  - `commands/dashboard.md`: **creo-memories ベースに全面書き換え**。`list_todos(status: "active", groupBy: "atlas")` を取得元とし、creo の todo が **active / done の 2 値**で中間状態を持たない事実に合わせ、`priority` → `updatedAt` 順で「今動いているもの」を表現する（旧「In Progress」相当の状態は再現しない）
  - `chronista-style` `4.4.0` → `4.5.0`: Issue 管理の SSOT を memory に変更。Issue-first の原則・Branch slug 規約・テストリストの 3 層 SSOT を memory ベースへ書き換え
  - `codeflow` `2.1.0` → `2.1.1` / `council` `1.0.0` → `1.0.1` / `route` `1.0.1` → `1.0.2`: 残存していた Linear 参照を除去
  - `commands/route.md` / `commands/sdg.md` / `hooks/session-start.sh`: Linear MCP 参照を creo-memories に置換
- `skills/cross-build-image/SKILL.md` / `skills/size-stepper/SKILL.md`: `~/repos/...` を指す参照を **「開発中のエイリアス — あるところには、ある」** として再定義。参照先を持つ環境でのみ解決でき、skill の動作条件ではないことを明示

### Fixed
- `skills/parallel-dev/SKILL.md`: VP の呼び出しが `vp flow_handoff`（MCP ツール名の形）になっていたのを、実際の CLI である `vp flow handoff <name> --task-spec <file|->` に修正（2 箇所）
- **`chronista-style` のスキルツリーが実態と乖離していた** — `4.5.0` → `4.6.0`
  - routing の入口であるルートスキルに `parallel-dev` / `cross-build-image` / `size-stepper` の 3 件が未記載で、実質そのスキルが隠れていた
  - 廃止済みの `fleetflow` が残っていた（marketplace からも削除済み。CLI 本体 `chronista-club/fleetflow` は継続）
  - 記載 15 件 = 実ディレクトリ 15 件を機械的に照合して一致を確認
- `README.md`: スキル一覧が 15 件中 7 件、コマンド表が 6 件中 4 件しか記載していなかったため全件に更新。スキルタイプの分類説明も表の種別と一致させた（`AI 協働` / `実装技術` の 2 分類を追記）
- **バージョン SSoT の記述をリポジトリ実態に同期**（Living Documentation）: `0.24.1` (#7) で内側の `.claude-plugin/marketplace.json` を撤去し `plugin.json` に一本化したにもかかわらず、`commands/release.md` / `README.md` / `CHANGELOG.md` ヘッダが `marketplace.json` を SSoT と記述したままだった。`/release` の Step 1 検出表がプラグインを検出できず手順が破綻するため修正。検出表には marketplace repo 形式も併記し、両方ある場合の優先順位（`plugin.json` が本体の正）を明示
- **`commands/release.md` の frontmatter が YAML として壊れていた**: `description: リリースバージョン（例: 0.3.0, 1.0.0）` の全角括弧内にある 2 つ目の `: ` でパース失敗し、ブロック全体（1 行目の `description` 含む）が失われていた。併せて、コマンド仕様に存在しない `arguments:` フィールドを正規の `argument-hint` に置換
- `commands/route.md`: `$ARGUMENTS` を使うのに `argument-hint` が無かったため追加
- `skills/{codeflow,route,size-stepper}/SKILL.md`: frontmatter の必須キーが `skill:` になっていたのを `name:` に統一（他 12 スキルは `name:`）
- `skills/cross-build-image/SKILL.md`: 同梱スクリプトの呼び出しが cwd 相対（`./build-and-push.sh`）で install 後に解決できなかったため `${CLAUDE_PLUGIN_ROOT}` 経由に修正
- `hooks/hooks.json`: `${CLAUDE_PLUGIN_ROOT}` が未クォートで、install パスにスペースが含まれると hook が起動しなかった。`bash "..."` 形式に修正（スペース入りパスで実行検証済み）

## [0.25.1] - 2026-07-31

### Added
- `.mcp.json.example`: プロジェクト共有可能な MCP サーバー雛形（gitnexus を bunx 起動で環境非依存に定義）。`bin/setup` / `bin/setup-windows` に `.mcp.json` 補完ステップを追加 — **共有 config store**（`$CHRONISTA_SHARED_CONFIG/claude/.mcp.json`、個人設定を集約した repo の `shared/` を想定。未設定なら example にフォールバック）への symlink を優先（`rm` / `git clean` で消えるのはリンクだけ、実体は store 側の git が保護）、store 不在時は example からコピー。Windows は symlink 不安定のため常にコピー運用。dangling symlink は掃除して再解決。運用原則: gitignore する手作りファイルは復元手段（example / 生成スクリプト）とセットにする

### Changed
- `code-review` SKILL.md を `2.0.0` → `2.1.0`: §C 定期実行を削除（未使用のため）。`reference/periodic-setup.md` も削除し、§D 共通規律 → §C、§E 既存スキルとの関係 → §D に再番号。`reference/examples.md` / `reference/modes.md` からも定期 review への言及を除去

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

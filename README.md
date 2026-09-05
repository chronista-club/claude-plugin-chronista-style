# Chronista Style Plugin

Chronista のプロダクト群を横断する**共通の開発スタイル基盤**。どのプロダクトでも同じ流儀で「強く美しいプロダクト」に育てていくために、Spark → Conception → GO の開発フロー・Living Documentation・規律スキル（TDD / デバッグ / 検証）を統合する。

> **バージョン**: プラグイン本体は `.claude-plugin/plugin.json` を、各スキルは個別の `SKILL.md` frontmatter を参照。履歴は [CHANGELOG.md](./CHANGELOG.md) に記録。

## インストール

```bash
/install chronista-club/claude-plugin-chronista-style
```

## スキル一覧

| スキル | 種別 | 説明 |
|--------|------|------|
| `chronista-style` | 入口 | North Star・設計哲学・基本姿勢・プロジェクト管理の規約。各スキルへ routing する |
| `codeflow` | プロセス | Spark（想起）→ Conception（構想）→ GO で作業に切り替え、SDG で仕様・設計を記録する開発フロー |
| `parallel-dev` | プロセス | 並列開発の道具選び。「隔離・出荷」2 層モデルで worktree / VP lane / stacked PR を判断 |
| `spec-design-guide` | 文書 | spec（What & Why）・design（How）・guide（Usage）を `docs/` に書き、コードと同じ PR で育てる |
| `tdd` | 規律 | テストファーストで実装する RED-GREEN-REFACTOR サイクル |
| `systematic-debugging` | 規律 | 根本原因を特定してから修正する 4 ステップデバッグ |
| `verification` | 規律 | 証拠なき完了宣言を防ぐ。検証コマンド実行 → 出力確認 → 主張 |
| `council` | AI 協働 | 4 voice の合議で意思決定。多義的なトレードオフや go/no-go 判断に |

規律 3 スキルは該当場面で省略しない。それ以外の該当判断はモデルに委ねる。

## コマンド

| コマンド | 説明 |
|----------|------|
| `/spark` | 降ってきたアイデアを解釈ゼロで memory に pack。一手で終わる |
| `/codeflow` | 開発セッションを開始。理解を提示してから該当ステップに入る |
| `/sdg` | spec / design / guide のひな形を `docs/` に起こす |
| `/release` | リリースの背骨（版・CHANGELOG・nightly → main・tag・GitHub Release）。尻尾はプロジェクト側に委譲 |

## 開発フロー

```
Spark（想起、どちらからでも）→ Conception（構想: 調べる・話す・理解を書く・合議、順不同）→ GO → SDG → Branch & PR → Implementation → Release → Learning
```

硬い線は GO の一本だけ。詳細は `codeflow` スキルを参照。

## hooks

- **SessionStart**: git コンテキストと Atlas 候補、規律エッセンス 4 行を注入
- **Stop**: `fabrication-tripwire.sh` — 観測していないツール出力を最終メッセージに書いたら差し戻す（fail-open）

## 関連プラグイン

| プラグイン | 説明 |
|-----------|------|
| [creo-memories](https://github.com/chronista-club/claude-plugin-creo-memories) | 永続記憶システム（MCP Server） |

## ライセンス

MIT

---
description: 仕様・設計・ガイドドキュメントを起こす。まず何を作るか尋ねる
---

# SDG 起動

`spec-design-guide` スキルのエントリポイント。**ひな形生成までを1コマンドで**。

## 実行手順

### 1. 種類の選択

`AskUserQuestion` で尋ねる:

> 「どの種類のドキュメントを作りますか？」

- **spec** — What & Why（仕様・目的・スコープ・要件）
- **design** — How（アーキテクチャ・データモデル・実装方針）
- **guide** — Usage（使い方・ベストプラクティス・トラブルシュート）

### 2. 対象のキャプチャ

`AskUserQuestion` で対象を特定:

> 「対象は？」

- **現ブランチに紐づく memory** — `mcp__creo-memories__search` でブランチ名から引く
- **直近の commit から推測** — `git log -5 --oneline` の変更内容から対象機能を推測
- **フリーテキストで指定** — ユーザーが直接入力

### 3. ひな形生成

選択された種類に応じて保存先と構成を切り替える。

| 種類 | 保存先 | 構成 |
|------|--------|------|
| spec | `docs/spec/{NN}-{kebab-case}.md` | Abstract → Motivation → Scope → Requirements（REQ-ID 付き） |
| design | `docs/design/{NN}-{kebab-case}.md` | Abstract → Architecture → Data Model → Implementation |
| guide | `docs/guide/{NN}-{kebab-case}.md` | Overview → Prerequisites → Usage → Troubleshooting |

本文は `docs/` のみに置く（Creo Memories には書かない）。`{NN}` は既存ファイルの最大番号 + 1。Status は `Draft` から始め、コードと同じ PR で更新する。

### 4. ヘッダと要件 ID

ヘッダは Status（Draft）と Related（spec 番号・起票 memory）と対象（コードパス）だけ。Author や日付は書かない。spec でトレーサビリティが要るなら `REQ-{NAME}-{NNN}` を振る（任意。NAME はドメインの短い語を提案して進める）。

### 5. 相互参照

生成したファイルのパスを提示する。対象に起票 memory があれば、ドキュメントのヘッダ（Related）に memory ID を書き、memory 側にはファイルパスを追記して往復を閉じる。

## Living Documentation

> 文書には What、memory には Why

生かし方（同じ PR で触る、書き換えより追記、消さず Deprecated）は `spec-design-guide` スキルを参照。

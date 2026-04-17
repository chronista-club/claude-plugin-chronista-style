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

- **現ブランチに紐づく Linear Issue** — `mcp__linear__get_issue` でブランチ名から引く
- **直近の commit から推測** — `git log -5 --oneline` の変更内容から対象機能を推測
- **フリーテキストで指定** — ユーザーが直接入力

### 3. ひな形生成

選択された種類に応じて保存先と構成を切り替える。

| 種類 | 保存先 | 構成 |
|------|--------|------|
| spec | Creo Memories（category: `spec`） | Abstract → Motivation → Scope → Requirements（REQ-ID 付き） |
| design | Creo Memories（category: `design`） | Abstract → Architecture → Data Model → Implementation |
| guide | Creo Memories（category: `guide`）+ `docs/guide/` にコピー | Overview → Prerequisites → Usage → Troubleshooting |

**guide のみデュアルストレージ**: Creo Memories を正、`docs/guide/` に同内容を書き込む。更新時は必ず両方を同期。

### 4. 要件ID（spec の場合のみ）

spec 作成時は `REQ-{NAME}-{NNN}` 形式で要件 ID を **Claude が候補を3つ提示** し、`AskUserQuestion` でユーザーに選ばせる（または新しい NAME を入力させる）。

### 5. 記録確認

生成した memory の `id` を提示し、どこで参照できるか（Creo Memories の URL など）を返す。

## Living Documentation 原則

> ドキュメント = What changed、creo-memories = Why changed

SDG ドキュメントとコードは常に同期。不一致はバグとして扱う。

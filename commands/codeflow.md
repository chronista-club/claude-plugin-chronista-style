---
description: ヒアリングファースト開発セッションを起動。まず何から入るか尋ねる
---

# Codeflow 起動

`codeflow` スキルのエントリポイント。**固定実行はしない。** まずユーザーの意図をキャプチャしてから該当ステップへ接続する。

## 実行手順

### 1. 対象のキャプチャ

ユーザーのメッセージに既に「何を作る / 何を改善する」が含まれていればそれを採用。含まれていなければ `AskUserQuestion` で尋ねる:

> 「今回のセッション、何を作りたい / 何を改善したいですか？」

フリーテキスト回答で受ける。

### 2. ステップの選択

続けて `AskUserQuestion` で入口を選ばせる:

> 「どのステップから入りますか？」

- **Discovery** — まず調査する。コードベース読解 + creo-memories の `search` で関連記憶を呼び戻す
- **Discussion** — 調査は済んでいるので方向性を議論したい
- **Hearing** — 方向性は決まっているので詳細を詰める（`/hearing` と同等）
- **既存タスクを続ける** — `mcp__creo-memories__list_todos` と `search` で前回の文脈を復元

### 3. 選択に応じた初期アクション

| 選択 | 初期アクション |
|------|---------------|
| Discovery | `search` + 現ブランチの `git log`、関連ファイルの読解を開始 |
| Discussion | 現時点の知見を 3-5 行にまとめて提示、`AskUserQuestion` で方向性を問う |
| Hearing | 質問候補を抽出 → `create_todo` で flow ドメインに登録（`/hearing` に委譲） |
| 既存タスクを続ける | `list_todos` の結果を要約し、次にやる候補を `AskUserQuestion` で選ばせる |

## 起動後の流れ

選択されたステップから `codeflow` スキル本体のフロー（Discovery → Discussion → Hearing → SDG → Branch & PR → Implementation → Release → Learning）に接続する。ステップは**名前で参照**し、番号は使わない。

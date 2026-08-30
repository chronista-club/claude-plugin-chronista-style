---
description: 全プロジェクトの進行中タスクを VP Canvas に一覧表示。creo-memories が SSOT。
---

# Dashboard

全プロジェクトの active な todo を VP Canvas に表示する。

## 手順

### 1. データ取得

creo-memories から active な todo を取得する。**active のみ**（done は不要）。

```
mcp__creo-memories__list_todos(status: "active", groupBy: "atlas", limit: 50)
```

`groupBy: "atlas"` で Atlas（プロジェクト）別にグルーピングされた結果が返るので、
クライアント側で集計する必要はない。

全体の完了率も並べたい場合は補助的に:

```
mcp__creo-memories__project_progress(group_by: "atlas")
```

### 2. 並び順

creo の todo は **active / done の 2 値**で、「進行中」という中間状態を持たない。
状態ラベルを増やす代わりに、以下の順で並べて「今動いているもの」を上に出す:

1. `metadata.priority`（high → medium → low）
2. `updatedAt`（新しい順）

直近に更新された todo ほど、実際に手が動いているタスク。

### 3. VP Canvas に表示

`mcp__vantage-point__show` で HTML を表示する。

表示要素:

| 要素 | 取り出し方 |
|------|-----------|
| プロジェクト名 | groupBy の Atlas 名 |
| 見出し | `content` の **1 行目**（先頭の `#` と装飾を除去） |
| 優先度 | `metadata.priority`（色分け: high=赤 / medium=黄 / low=灰） |
| 最終更新 | `updatedAt` を相対表記（「3 日前」等） |
| タグ | `metadata.tags` を小さく添える |
| ID | `mem_xxx`（後から参照・追記するため） |

`content` は Markdown の長文なので、**1 行目だけを見出しとして使う**。
本文全体を Canvas に流し込まない。

### 4. 表示のみ

ダッシュボードは**読み取り専用**。状態を変える操作は別コマンドで行う。

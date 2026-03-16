---
description: 全プロジェクトの状況を VP Canvas に一覧表示。Linear が SSOT。
---

# Dashboard

全プロジェクトの Issue 状況を VP Canvas に表示する。

## 手順

### 1. データ取得

Linear MCP で Issue を取得する。**In Progress と Todo のみ**（Done は不要）。

```
list_issues(state: "In Progress", limit: 50)
list_issues(state: "Todo", limit: 50)
```

### 2. プロジェクト別に集計

取得した Issue を `project` フィールドでグルーピングする。

### 3. VP Canvas に表示

`mcp__vantage-point__show` で HTML を表示する。

表示要素:
- プロジェクト名 + チームキー
- 各 Issue: ID、タイトル、ステータス（色分け）、優先度
- In Progress → Todo の順

### 4. 表示のみ

ダッシュボードは**読み取り専用**。アクションは別コマンドで。

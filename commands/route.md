---
description: Issue からゴールへの最適な path を探索（Survey→Plot→Compare→Choose→Confirm→Travel→Log）
argument-hint: "[issue-id]"
---

# Route 起動

`route` スキルのエントリポイント。Issue を最小スコープで完走させるための経路探索フローを走らせる。

## 実行手順

### 1. 対象 Issue のキャプチャ

`$ARGUMENTS` に Issue ID があればそれを採用。なければ `AskUserQuestion` で尋ねる:

> 「どの Issue の経路を探索しますか？ (例: mem_xxx、または機能名)」

Issue ID 以外にフリーテキストで「この機能追加」のような記述もあり得る。その場合は該当しそうな memory を検索して候補を提示する。

### 2. Survey の実行

指定 Issue に対して以下を並列に収集:

- creo-memories で memory 本文と関連 memory（derivedFrom / references）を取得
- `git log` で直近の関連コミット
- コードベースを Grep/Glob で探索（Issue 本文のキーワードから）
- creo-memories で関連記憶を `search`（特に `case-study` + `route` タグ）

出力: **Inventory**（既に実装済みの項目）/ **Dependencies** / **Unknowns** を 3 項目程度にまとめる。

### 3. Plot: 経路候補の列挙

最低 **2 本**、通常 **3-4 本**の path 候補を描く:

- **最短 path**: 真の差分だけ触る最小構成
- **安全 path**: 多少遠回りでも破壊リスクが低い
- **拡張 path**: 将来機能も巻き込む（通常は却下候補として比較に入れる）
- **放棄 path**: Issue を close / 後回しにする判断（常に入れる）

### 4. Compare: 採点

各 path を以下の評価軸で相対比較:

| 評価軸 | 内容 |
|---|---|
| Cost | 実装時間、PR サイズ、レビュー負荷 |
| Safety | 破壊影響、ロールバック容易性 |
| Unblock | 後続タスクをどれだけ解放するか |
| YAGNI risk | 未使用の抽象を先に作っていないか |

表形式で出力（厳密な数値は不要、相対的に「高/中/低」でよい）。

### 5. Choose: 推奨提示

最適 path を 1 本選び、理由を 1-2 行で付記。選ばなかった path の価値ある要素は **フォローアップ Issue 候補**として明示。

### 6. Confirm（ユーザー承認）

path を提示したら、GO を得てから Travel に移る。「この最小スコープで進めて OK ですか？」で十分。別の path が選ばれたら、その path の Travel に移る。

### 7. Travel / Log は通常フロー

Travel（実装・PR）と Log（記録）は通常の開発フロー（`codeflow`）に委譲してよい。Route の仕事は **Confirm まで**が主眼。

完走後、ユーザーに Log の記録を促す（memory への追記 or PR description + creo-memories の case-study タグ）。

## 引数

- `$ARGUMENTS`: Issue ID または自然言語の Issue 記述（省略可）

## 例

```
/route mem_xxx
/route GFP dev 移行
/route       ← 引数なし、AskUserQuestion で対象を聞く
```

## 関連

- スキル本体: `route/SKILL.md`
- 姉妹スキル: `codeflow`（開発フロー全体）、`spec-design-guide`（SDG 文書化）

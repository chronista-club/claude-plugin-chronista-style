---
description: 開発セッションを起動。理解を提示してから該当ステップに入る
---

# Codeflow 起動

`codeflow` スキルのエントリポイント。固定手順は踏まず、メニューで選ばせない。

## 実行手順

1. **対象** — メッセージに「何を作る / 何を改善する」があればそれを採用。なければ地の文で聞く
2. **現在地** — creo-memories の `search` と現ブランチの `git log` で、関連する記憶と状態を拾う。既存タスクの続きなら `list_todos` から該当 memory を引く
3. **理解の提示** — 分かったこと、これからやること、置いた仮定、迷っている点を短く書く。どのステップ（Discovery / Discussion / Hearing / 実装）から入るかは、この提示の中で自分の判断として述べる
4. **ズレと分岐** — 理解がズレていそうな所と、ユーザーが選ぶべき分岐だけ聞く。GO で走る（`codeflow` の「実装前の合意」）

## 起動後の流れ

提示したステップから `codeflow` スキル本体のフロー（Discovery → Discussion → Hearing → SDG → Branch & PR → Implementation → Release → Learning）に接続する。ステップは**名前で参照**し、番号は使わない。

# Code Review — 実例

`SKILL.md` の各セクションの実例。

---

## 例 1: Quick mode (PR シップ前)

**状況**: PR #203 (vp-app Phase 2) をマージしようとしている、まず Quick で確認したい。

```
> 「PR #203 を Quick でレビューして」

> git diff --stat HEAD ^main → 7 files changed, 553 insertions(+), 301 deletions(-)
> → 854 行、Standard mode 推奨。本当に Quick で？

> 「いや、Standard で」

> ヒアリング: 出力先は？ → 「PR コメント」

> Dispatch (parallel):
>   Moody Blues  → CI + 4 視点
>   Purple Haze  → architecture / runtime flow

> Aggregate:
>
> | # | severity | location | 問題 |
> |---|---|---|---|
> | M1 | 🟡 Minor | app.rs:325 | daemon 復帰検知なし |
> | M2 | 🟡 Minor | app.rs:758 | HashMap leak |
>
> Verdict: SHIP IT (Minor のみ)
> PR #203 にコメント投稿済
```

---

## 例 2: Deep mode (大規模 refactor 前)

**状況**: VP-94 epic の Phase 3 を着手する前に、Phase 2 までの構造を Deep でレビューしたい。

### Phase 1: Sweep (parallel)

```
> ヒアリング:
>   - 対象: branch (mako/vp-100-...) と main の diff
>   - 深さ: 全部
>   - 優先: アーキ + 構造的負債
>   - 出力: canvas + docs/review/

> Plan:
>   Phase 1 dispatch:
>     Aerosmith ← Pass 1 (アーキ全体) + Pass 8 (長いモジュール)
>     Moody Blues ← Pass 2, 4, 5 (モジュール / 横断 / バグ)
>     Purple Haze ← Pass 3 (runtime flow)
>     Spice Girl ← Pass 4 (test coverage)
>   ETA: ~10 分

> 「OK」

> [並列 dispatch 4 件、結果を待つ]
```

### Phase 1 結果

```
| # | severity | location | 観点 | 問題 |
|---|---|---|---|---|
| B1 | 🔴 Major | app.rs:325 | runtime | daemon 復帰検知なし |
| B2 | 🔴 Major | app.rs:758 | memory | HashMap leak |
| A1 | 💡 Idea | app.rs (763 行) | 構造 | god file、Phase 3 で分割 |
| ... |
```

### Phase 2: Deep dive (iterative)

```
> 「次の観点どうする？」

> 「A1 (god file) を深掘りしたい」

> Purple Haze ← app.rs の責務分析、分割案提示

> 結果:
>   分割案: app/state.rs / poller.rs / sidebar_html.rs / sidebar_ipc.rs / event_loop.rs

> 「次の観点どうする？」

> 「もう十分」

> Aggregate (Phase 1 + Phase 2)
> Output:
>   - canvas (vantage-point:show)
>   - docs/review/vp-100-phase2-review.md
> Decision:
>   - merge 可能 (Major fix 後)
>   - god file 分割は Phase 3 と同梱
```

---

## 例 3: 定期 Deep (月次)

**状況**: `/schedule` で登録した monthly-main-deep-review が起動。

```
> [自動起動: 2026-05-01 09:00]
>
> Plan (default):
>   - 対象: main 全体
>   - 深さ: 浅く全体 (default、Phase 1 only)
>   - 出力: canvas + docs/review/main-monthly-2026-05.md

> Phase 1 dispatch (parallel, 4 Stand)
>
> Aggregate
>
> Major issue 自動起票 (Linear):
>   - VP-XXX: app.rs HashMap leak (M1 から起票)
>   - VP-YYY: ...
>
> docs/review/main-monthly-2026-05.md に保存
>
> 完了通知 (Slack / Discord)
```

---

## 例 4: 受信側 (B mode)

**状況**: ユーザが「ここのエラーハンドリング、let-else 使ったら？」とコメント。

```
❌ NG response:
> 「素晴らしい指摘ですね！すぐ実装します！」

✅ OK response:
> 「let-else を使う候補は app.rs:325-340。
>    ただし現状の `match` は 3 つの分岐を返してて、
>    let-else だと early return が増える設計になる。
>    具体的にどの行を let-else にしたい？」

[ユーザの返答待ち、検証してから着手]
```

---

## 例 5: 反論 (B mode)

**状況**: 外部 reviewer (Stand) が「この関数を public にすべき」と指摘。

```
> [検証]
> grep -r "this_function" → このモジュール内でしか呼ばれていない
> 
> ✅ 反論:
> 「このコードベースで現在この関数の呼び出しは internal のみ
>    (`mod.rs` 内 1 箇所)。public にする理由は？
>    YAGNI で internal 維持を提案。」
```

---

## チューニング tips

- **Quick で何も出ない** → そもそも Quick で十分。Standard 化は不要
- **Standard で Major が連発** → Phase 2 に深掘り (iterate) を入れて Deep 化
- **Deep が 30 分超** → Stand を 4 → 3 に絞る、または Pass を 8 → 5 に減らす
- **定期 review で同じ Major が毎回出る** → 該当 issue を Linear で固定追跡、review からは除外

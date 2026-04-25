# Code Review — 定期実行 (Periodic Setup)

`SKILL.md §C` の補完。`/schedule` 経由で定期 review を回す手順。

---

## 基本方針

**毎日 Deep は重い**。代わりに:
- **毎日** — 各自の PR シップ時に Quick (手動)
- **週次** — main / 主要 branch に Quick で drift 検出 (自動)
- **月次** — main に Deep で構造的負債の棚卸し (自動)
- **リリース前** — release branch に Deep 1 回 (手動)

---

## /schedule で定期登録

`chronista-plugins` の `/schedule` skill 経由で remote agent (routine) を登録。

### 例 1: 毎週月曜 09:00 — main に Quick mode

```
/schedule

routine name: weekly-main-quick-review
cron: 0 9 * * 1  (毎週月曜 09:00 JST)
prompt:
  「main branch に対して code-review skill の Quick mode を実行。
   Moody Blues に dispatch、結果は canvas (vantage-point:show) に投影。
   Major issue があれば Linear に Issue 起票。」
```

### 例 2: 毎月 1 日 — main に Deep mode

```
/schedule

routine name: monthly-main-deep-review
cron: 0 9 1 * *  (毎月 1 日 09:00 JST)
prompt:
  「main branch に対して code-review skill の Deep mode を実行。
   Hybrid Z で 6-8 pass、ヒアリングは default (浅く全体)、
   結果は canvas + docs/review/main-monthly-<YYYY-MM>.md に保存。
   Severity Major のものは Linear に起票、project に紐付け。」
```

### 例 3: リリース前 — release branch に Deep

リリース branch を切るタイミングでマニュアル実行 (cron ではなく `/schedule` の one-time):

```
/schedule one-time

target: release branch (例: release/v1.2.0)
when: 即時 (or 指定日時)
prompt:
  「release/v1.2.0 に対して code-review Deep mode を実行。
   特にセキュリティ (Pass 4) と長いモジュール (Pass 8) を重点。
   結果は PR コメント + Linear release issue に追記。」
```

---

## アンチパターン

❌ **毎日 Deep を schedule** — 重い、ノイズが増える
❌ **PR ごとに Deep を schedule** — そのトリガーは PR webhook、scheduler の役目ではない
❌ **結果を投げっぱなし** — Major issue は必ず Linear / GitHub Issue に紐付ける、誰が直すか明示

---

## 結果のハンドリング

定期 review が走った後の処理:

1. **Major issue** → Linear / GitHub Issue 自動起票 (assignee は branch owner or team lead)
2. **Minor issue** → docs/review/ に蓄積、月次でまとめて見直し
3. **Idea** → memory に保存 or backlog issue
4. **Drift 検出** (週次 Quick で問題ナシだが何か変わってる) → ユーザに通知 (Slack / Discord)

---

## チューニング

定期 review が **noise になってきた** ら:

- cron 間隔を伸ばす (週次 → 隔週 → 月次)
- Severity 閾値を上げる (75 → 85)
- Pass を絞る (Deep の 8 観点 → 重点 3-4 観点に減らす)
- Stand を絞る (Moody Blues + Purple Haze だけ等)

`reference/modes.md` の Standard mode に近づける形で軽量化。

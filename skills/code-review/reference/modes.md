# Code Review — Modes 詳細

`SKILL.md §A.2` の補完。Quick / Standard / Deep の具体フロー。

---

## Quick mode

**用途**: PR < 200 行 / single concern / 毎日のシップ前

**所要時間**: ~30 秒

**ヒアリング**: ほぼスキップ。出力先だけ確認 (デフォルト: PR コメント)。

### フロー

```
git diff --stat HEAD ^main で規模確認
  ↓
Moody Blues 1 発 dispatch
  ├─ CI (typecheck / lint / build / test)
  ├─ Auto-fix (biome check --write 等)
  └─ 4 視点 review (CLAUDE.md / Bug / diff history / comments)
  ↓
判定: SHIP IT / NEEDS WORK / BLOCKED
  ↓
出力: PR コメント (gh pr comment) or コンソール
```

### 例

```
# 「PR #203 を Quick で見て」と言われた時

git diff --stat HEAD ^main
# 5 files changed, 87 insertions(+), 12 deletions(-)
# → 87+12 = 99 行 → Quick 妥当

Agent(subagent_type=moody-blues, prompt="PR #203 をレビュー、4 視点 + CI、PR コメント形式で")

# 結果: SHIP IT、PR #203 にコメント投稿済
```

---

## Standard mode

**用途**: PR 200-1000 行 / 複数モジュール / 普通の機能追加

**所要時間**: 3-5 分

**ヒアリング**: 1-2 問
- 出力先 (canvas / md / PR コメント)
- 重点観点 (任意、なければ default)

### フロー

```
git diff --stat HEAD ^main で規模確認
  ↓
ヒアリング (1-2 問)
  ↓
2-3 Stand 並列 dispatch (同一メッセージ内で複数 Agent ツール呼び出し)
  ├─ Moody Blues (CI + 4 視点 + 信頼度スコア)
  ├─ Purple Haze (architecture / runtime flow 深掘り)
  └─ Spice Girl (test coverage gap、任意)
  ↓
Aggregate (severity matrix で構造化)
  ↓
出力 (canvas / md / PR コメント)
```

### Dispatch 例

```
# 同一メッセージ内で並列起動

Agent(subagent_type=moody-blues, prompt="...")
Agent(subagent_type=purple-haze, prompt="...")
Agent(subagent_type=spice-girl, prompt="...")
```

各 Stand の StandContext (Aerosmith dispatch 経由なら自動付与) を含めることで scope を揃える。

---

## Deep mode

**用途**: PR > 1000 行 / 大規模 refactor / merge 前最終確認

**所要時間**: 10-30 分

**ヒアリング**: 3-4 問
- スコープ (branch / PR / 特定ファイル / 全体)
- 深さ (浅く全体 / 深く特定 / 全部)
- 優先関心事 (パフォ / セキュリティ / 設計 / バグ / UX)
- 出力先

### Hybrid Z (推奨)

```
Phase 1: Sweep (parallel)
  ├─ Aerosmith → Pass 1 (全体アーキ) + Pass 8 (長いモジュール)
  ├─ Moody Blues → Pass 2 (モジュール) + Pass 5 (バグ) + Pass 4 (横断)
  ├─ Purple Haze → Pass 3 (実行時フロー)
  └─ Spice Girl → Pass 4 (テスト観点)

Phase 1 結果集約 → ユーザに見せる
  ↓
Phase 2: Deep dive (iterative)
  ├─ ユーザに「これ深掘りしたい」を 1 個選んでもらう
  ├─ Purple Haze で深掘り (該当ファイル / 関数の git history まで)
  ├─ 結果見せる → 「次の観点どうする？」
  └─ 「もう新規の指摘は薄い」と判断したら終了

Phase 1 + Phase 2 をマージ → 最終 severity matrix

出力 (canvas + PR コメント等、複数同時 OK)

決定提案: merge / fix / split
```

### モード切替の判断

ヒアリング時に深さを聞いて:
- **浅く全体** → Phase 1 のみ
- **深く特定** → Phase 2 のみ (既知の懸念を深掘り)
- **全部** → Hybrid Z

---

## モード比較表

| 観点 | Quick | Standard | Deep |
|---|---|---|---|
| 所要時間 | ~30s | 3-5min | 10-30min |
| Stand 数 | 1 | 2-3 | 4-6 |
| ヒアリング | スキップ | 1-2 問 | 3-4 問 |
| Iterate | なし | なし | あり (Deep のみ) |
| 出力 | コンソール / PR コメント | canvas / md / PR コメント | canvas + md + PR コメント (複数) |
| 適用 PR 規模 | <200 行 | 200-1000 行 | >1000 行 / refactor |

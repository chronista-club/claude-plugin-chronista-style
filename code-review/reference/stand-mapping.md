# Code Review — 観点 ↔ Stand マッピング詳細

`SKILL.md §A.3` の補完。各 Pass の具体的な観点と Stand の役割。

---

## Pass 一覧 (8 観点)

### Pass 1: 全体アーキテクチャ

**観点**:
- モジュール境界 / 責務分担
- 設計と実装の一致
- 依存関係 / 循環依存
- レイヤリング (data / logic / UI)

**推奨 Stand**: **Aerosmith** (俯瞰)

**補助**: 必要なら Purple Haze で個別領域を深掘り

---

### Pass 2: モジュールごと品質

**観点**:
- 各 file の凝集度
- 過度な責務
- 命名の一貫性
- 公開 API の妥当性

**推奨 Stand**: **Moody Blues** (4 視点 review)

**観察ポイント**:
- CLAUDE.md コンプライアンス
- バグスキャン
- diff 関連の変更履歴
- TODO / FIXME / WARNING の整合性

---

### Pass 3: 実行時フロー / threading / IPC

**観点**:
- thread 構成
- event flow / message passing
- race condition
- lock / mutex / channel の使い方
- async / await の依存関係

**推奨 Stand**: **Purple Haze** (深掘り研究)

**補助**: Moody Blues (diff history で直近の変更が壊してないか)

---

### Pass 4: 横断的関心事

**観点**:
- error handling (graceful fallback / silent fail)
- logging (level / verbosity / signal/noise 比)
- security (input validation / SSRF / XSS / IPC injection)
- testing (coverage gap / boundary condition)

**推奨 Stand**:
- general: **Moody Blues**
- testing 専用: **Spice Girl** (t-wada 流テストピラミッド観点)

---

### Pass 5: 具体バグ / subtle issue

**観点**:
- ロジックエラー / null チェック漏れ / 型不整合
- メモリリーク (HashMap が削除されない等)
- 競合状態
- edge case (空入力 / overflow / 重複)

**推奨 Stand**: **Moody Blues** (信頼度スコア 75+ で報告)

**Severity 付け**:
- 🔴 Major: 機能破壊 / データ消失 / セキュリティ
- 🟡 Minor: 動くが望ましくない
- 💡 Idea: 改善提案

---

### Pass 6: UX / accessibility

**観点**:
- キーボードナビゲーション
- screen reader 対応 (aria 属性)
- フォーカス可視化
- 永続化 (再起動時の状態維持)
- 操作の一貫性

**推奨 Stand**: **手動レビュー** (現状 Stand 候補なし)

UI 特化 Stand を将来追加する場合のホルダー。

---

### Pass 7: ビルド / 配布

**観点**:
- bundle size
- 起動時間
- hot reload 可否
- 開発体験 (DX)
- packaging / signing / release flow

**推奨 Stand**: **Gold Experience** (build / migrate / deploy / health check)

---

### Pass 8: 長いモジュール / 分割整理

**観点**:
- god file 検出 (`wc -l` で 500+ 行)
- 責務漂流 (file 名と中身のズレ)
- 分割案の提案

**推奨 Stand**: **Aerosmith** (俯瞰) + **Purple Haze** (深掘り)

**判断基準**:
- 500 行未満 → OK
- 500-800 行 → 警告、責務確認
- 800+ 行 → 分割推奨

---

## Stand 役割サマリー (review 文脈)

| Stand | 主領域 | review での出番 |
|---|---|---|
| **Aerosmith** | Orchestrator | Pass 1, 8 / 全体 dispatch / 集約 |
| **Moody Blues** | Quality Gate | Pass 2, 4, 5 (CI + 4 視点 + 信頼度) |
| **Purple Haze** | Research | Pass 3 / 深掘り (Phase 2) |
| **Spice Girl** | Test Generation | Pass 4 (testing aspect) |
| **Gold Experience** | Deploy | Pass 7 (build / 配布) |
| **Sticky Fingers** | Shipping | review 後の fix commit / merge |
| **Sex Pistols** | Parallel Workers | (review 自体には使わない、Aerosmith が parallel dispatch を担う) |

---

## 並列 dispatch 推奨組合せ

**依存なしで並列出せる**:
- Pass 1 + 2 + 3 + 4 + 7 + 8 — 全て独立観点

**Sequential 推奨**:
- Pass 5 (バグ) は Pass 2 (モジュール review) の output を入力にすると質↑
- Pass 6 (UX) は手動なので並列 dispatch には乗らない

**Hybrid Z での並列例 (Standard / Deep)**:

```
Phase 1 (parallel):
  Aerosmith ← Pass 1, 8
  Moody Blues ← Pass 2, 4, 5
  Purple Haze ← Pass 3
  Spice Girl ← Pass 4 (test)
  Gold Experience ← Pass 7

Phase 2 (sequential, iterative):
  Purple Haze で深掘り (Phase 1 の特定 issue)
  ↓
  ユーザに「次の観点どうする？」
  ↓
  必要なら別 Stand 再 dispatch
```

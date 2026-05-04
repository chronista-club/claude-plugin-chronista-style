---
skill: size-stepper
description: design token (spacing / typography / radius 等) を 「演奏できる Live Token」 として扱う architecture skill。 TS class + Solid signal + CSS scope mirror + MIDI 2.0 連携で 物理 fader 演奏しながら token を tweak、 lock + Export to clipboard で const 化までの lifecycle を提供
tags: [design-system, design-token, css-variable, solid, midi, live-tweak, korg-keystage, fleetstage]
version: 1.0.0
origin: fleetstage-hq (2026-05-04, commits 87207917 / 735b5188 / 97e98a24)
---

# Size Stepper Skill

**Size Stepper**は、 design token を **「演奏できる Live Token」** として扱う 4 層 architecture です。 spacing scale / typography / radius 等の数値 token を、 開発者が **物理 MIDI fader を動かしながら tweak** できる Editor + 反映システムを提供します。

## Core principle: design token を演奏する

> **「token は const ではなく、 まず楽器」**

設計の流れ:

1. **探索** — fader / slider で動的に動かしながら良い値を探す
2. **確定候補** — lock per-key で freeze、 const 化候補にマーク
3. **焼き戻し** — Export to clipboard で TS literal 生成 → source code に paste
4. **運用** — git commit、 prod 反映 (= 通常の const)

const 化 *してもしなくてもよい* のが要点。 design token は探索 phase が長く、 lock/unlock を繰り返しながら徐々に固める。

## 4 層 architecture

```
┌─────────────────────────────────────────┐
│  Layer 4: Editor + MIDI connector       │  StepperEditor.tsx + midi/*.ts
│  (UI tab + slider + lock + bounds)      │
└─────────────────────────────────────────┘
                  ▲ ▼
┌─────────────────────────────────────────┐
│  Layer 3: CSS bridge (<style> inject)   │  inject-helper.ts
│  (cascade で var(--spacing-*) 上書き)   │
└─────────────────────────────────────────┘
                  ▲ ▼
┌─────────────────────────────────────────┐
│  Layer 2: Hierarchy (SSOT)              │  design/index.ts
│  (UI → BUTTON / HEADER 親子継承)        │
└─────────────────────────────────────────┘
                  ▲ ▼
┌─────────────────────────────────────────┐
│  Layer 1: TS class (SizeStepper)        │  size-stepper.ts
│  (parent / overrides / mergedMemo)      │
└─────────────────────────────────────────┘
```

### Layer 1: TS class

```ts
class SizeStepper {
  constructor(name, parent, initial)
  values(): SizeMap        // merged parent + own (createMemo)
  set(key, px, opts?)      // lock-aware (lock 時 ignore)
  lock(key); unlock(key);
  derive(name, overrides)  // child stepper 作成
  setBoundsOverride(key, side, value)
  injectAt(scope)          // <style> tag を <head> に upsert
}
```

`createRoot` で wrap して dispose-safe。 Solid の `createSignal` + `createMemo` で reactive bridge。

### Layer 2: Hierarchy (SSOT)

```
UI (root) — { xs: 4, s: 8, m: 16, l: 24, xl: 32 }
├── BUTTON (.creo-btn scope、 UI inherit + override)
└── HEADER (.creo-header scope、 UI inherit + override)
```

merge 戦略は spread: `{ ...parent.values(), ...own }`。 child は parent を継承しつつ key 単位で override 可能。

### Layer 3: CSS bridge

各 namespace の `injectAt(scope)` が `<style>` tag を `<head>` に upsert:

```css
.creo-header {
  --spacing-xs: 4px;
  --spacing-s: 6px;   /* HEADER override */
  --spacing-m: 14px;  /* HEADER override */
  ...
}
```

cascade で scope 内 component の `var(--spacing-*)` 参照は override 値を pick up。 CSS scope = TS namespace mirror。

### Layer 4: Editor + MIDI

`StepperEditor` (dev only):
- namespace tab (UI / BUTTON / HEADER)
- per-key slider + lock toggle (🔒) + CC indicator
- bounds inline number input (両端 click-to-edit)
- "Add step" button (新 key 追加)
- MIDI Controller section (device 選択 + last dispatch log)
- "📋 Export to clipboard" (全 namespace の TS literal 生成)

`midi/` modules:
- `parse.ts` — UMP 32-bit (Chrome experimental) + MIDI 1.0 7-bit fallback
- `map.ts` — fader 0-127 を adjacent bound に linear map + precision rounding
- `listener.ts` — `onmidiumpmessage` + `onmidimessage` 両方 attach
- `auto-connect.ts` — page load 時 silent restore (localStorage device id 永続)
- `store.ts` — createRoot wrap の module-level signal store

## 主要 design choice

### adjacent ceiling

スライダー / fader の bounds は:
- **max = 次 step の値** (xs.max = s 値)
- **min = namespace の floor** (固定 0)

これで monotonic (xs ≤ s ≤ m ≤ l ≤ xl) を維持しつつ、 「8 で 100% 到達」 visualization が成立。 隣接連動 (sm の不要な動き) を回避するために min は固定にする。

### per-key precision

```ts
type Precision = "integer" | number;  // 数字 N = 10^-N step
```

- xs (0-8px) → precision 1 (= 0.1 step) で float tweak
- s/m/l/xl → integer (1px step) で round

token 型ごとに丸め単位を変える。 fader 0-127 解像度に対する mapping 精度が変わる (precision 1 で 80 step、 integer で約 16 step)。

### per-key lock

```ts
.lock("m")    // set ignore で freeze
.unlock("m")
```

Editor で 🔒 + warning color + slider disabled の visual marker。 const 化候補のフラグ。 lock 中は MIDI / slider 入力をすべて無視。

### bounds override

bar 両端の number input を click すると inline edit、 空欄 commit で削除 (= default 復帰)。 mint = override 値、 tertiary = default (adjacent / namespace 値)。

### Export to clipboard

```ts
exportRegistryAsTsLiteral(): string
```

全 namespace の current values を TS literal に生成 → clipboard copy → source の `src/design/index.ts` に paste で焼き戻し完了。

## Korg Keystage (MIDI 2.0) 連携

### 1 row pattern

8 fader (CC 0-7) で 1 row 全 namespace 制御:

| CC | namespace.key |
|---|---|
| 0 | UI.xs |
| 1 | UI.s |
| 2 | UI.m |
| 3 | UI.l |
| 4 | UI.xl |
| 5 | BUTTON.m |
| 6 | HEADER.m |
| 7 | HEADER.l |

CC 8-15 (knob row) は将来拡張枠で温存。

### MIDI 2.0 / 1.0 切替

- **UMP (32-bit)**: Chrome 130+ で experimental flag (`enable-experimental-web-platform-features`)、 解像度 0xFFFFFFFF (32-bit normalize)
- **MIDI 1.0 (7-bit)**: default fallback、 解像度 127

Korg Keystage は USB MIDI Class 1.0 互換 mode で接続するので、 default では 7-bit。 UMP mode 切替は機種によって設定 app 経由。

### auto-connect

```ts
tryAutoConnectMidi()    // page load 時 silent restore
selectMidiInput(id)     // user gesture で permission grant
```

permission granted state なら silent restore、 そうでなければ user click ("🎹 Connect MIDI") で 1 user gesture を消費して permission 獲得。 device id は localStorage に永続。

## いつこの skill を使うか

### 適用場面

- design system の数値 token (spacing / typography / radius / shadow / animation 等) を 探索的に tweak したい
- 複数の component / scope で **継承 + 部分 override** が必要な token (e.g. `.creo-header` だけ padding を絞めたい)
- 物理 controller (MIDI / OSC / touchbar 等) で UI を **演奏したい**
- token の確定 → const 化 lifecycle を仕組み化したい

### 適用しない場面

- token が静的 (mutable tweak 不要)、 一度書いたら変わらない
- production runtime で token を変えたい (= remote config 案件、 別 architecture)
- multi-user collaborative tweak (= server-side state 案件、 別 architecture)

## 実装 reference

fleetstage-hq の実コードが SSOT:

- `~/repos/fleetstage/crates/fleetstage-hq/ui/src/design/size-stepper.ts` — SizeStepper class
- `~/repos/fleetstage/crates/fleetstage-hq/ui/src/design/index.ts` — namespace SSOT + registry
- `~/repos/fleetstage/crates/fleetstage-hq/ui/src/components/StepperEditor.tsx` — Editor UI
- `~/repos/fleetstage/crates/fleetstage-hq/ui/src/midi/*.ts` — MIDI listener / auto-connect

関連 commit: `87207917` (architecture base)、 `735b5188` (adjacent-bound + per-key precision)、 `97e98a24` (bounds override + 5 tier rename)。

詳細 narrative: `~/.claude/projects/-Users-makoto-repos-fleetstage/memory/project_size_stepper_architecture.md`。

## 関連 skill / handbook

- `chronista-style` — ヒアリングファースト + 一問一答 + ユーモア
- `codeflow` — Discovery → Hearing → SDG → Implementation の workflow
- `~/repos/chronista-handbook/domain.md § Creo UI Design System` — handbook 上での domain knowledge

# Grokking Simplicity — エッセンス抽出

> 原典: [Grokking Simplicity](https://www.manning.com/books/grokking-simplicity) — Eric Normand (Manning, 2021)
>
> 関数型プログラミングの思考法を、どんな言語でも使える実践的スキルとして再構成した本。
> FP の学術的な側面（モナド、型理論等）ではなく、**日常のコード設計に効く部分** だけを抽出している。

---

## 核心: Actions / Calculations / Data

全てのコードは3つに分類される。これが本書の最も重要な概念。型も関数も式も、全てこの3つのどれかに属する。

### Data（データ）

**イベントについての事実。不変。**

```typescript
// Data の例
const user = { id: "u1", name: "Mako", role: "admin" };
const items = [{ name: "milk", price: 300 }, { name: "bread", price: 200 }];
const config = { port: 8080, host: "localhost" };
```

特徴:
- 何かが起きた結果の記録
- それ自体は何もしない（副作用なし）
- コピーしても安全
- 等値比較が簡単
- シリアライズ可能（JSON, DB, ネットワーク）

### Calculations（計算）

**入力から出力への純粋な変換。何度呼んでも同じ結果。**

```typescript
// Calculation の例
function totalPrice(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

function isAdmin(user: User): boolean {
  return user.role === "admin";
}

function applyDiscount(price: number, rate: number): number {
  return price * (1 - rate);
}
```

特徴:
- 副作用なし（DB 読み書き、ログ出力、時刻取得もしない）
- 同じ引数 → 常に同じ戻り値
- 呼ぶタイミングを気にしなくていい
- テストが簡単（入力を与えて出力を検証するだけ）
- 安全に並列実行できる

### Actions（アクション）

**外部世界と相互作用する。呼ぶタイミングと回数が重要。**

```typescript
// Action の例
async function saveUser(user: User): Promise<void> {
  await db.insert("users", user);  // DB書き込み = 副作用
}

function sendEmail(to: string, body: string): void {
  mailer.send(to, body);  // 外部送信 = 副作用
}

function getCurrentTime(): Date {
  return new Date();  // 呼ぶたびに結果が変わる
}

console.log("hello");  // 画面出力 = 副作用
```

特徴:
- 外部世界に影響を与える、または外部世界から影響を受ける
- **いつ** 呼ぶかが重要（順序依存）
- **何回** 呼ぶかが重要（2回呼べば2回メール送信）
- テストが難しい（モック、スタブが必要）
- デバッグが難しい（状態に依存）

---

## 原則1: Actions を最小化せよ

コードの大部分を Calculations と Data で構成し、Actions は境界に押し出す。

**悪い例: Action だらけ**

```typescript
function processOrder(orderId) {
  const order = db.getOrder(orderId);        // Action
  const tax = order.total * 0.1;             // Calculation（だが Action の中に埋まっている）
  const total = order.total + tax;           // Calculation
  db.updateOrder(orderId, { total });        // Action
  sendReceipt(order.email, total);           // Action
}
```

**良い例: Calculations を抽出**

```typescript
// Calculations（テスト容易、再利用可能）
function calcTax(amount: number, rate: number): number {
  return amount * rate;
}
function calcTotal(subtotal: number, tax: number): number {
  return subtotal + tax;
}

// Action（薄いシェル）
async function processOrder(orderId: string) {
  const order = await db.getOrder(orderId);
  const tax = calcTax(order.subtotal, 0.1);
  const total = calcTotal(order.subtotal, tax);
  await db.updateOrder(orderId, { total });
  await sendReceipt(order.email, total);
}
```

**ポイント**: Action の中からロジックを抽出して Calculation にする。Action は「接着剤」として薄く保つ。

---

## 原則2: Copy-on-Write（書き込み時コピー）

データを変更する代わりに、変更を加えた新しいコピーを作る。

```typescript
// ❌ 破壊的変更（元のデータが壊れる）
function addItem(cart: Item[], item: Item) {
  cart.push(item);  // 元の配列を変更
}

// ✅ Copy-on-Write（元のデータは無傷）
function addItem(cart: Item[], item: Item): Item[] {
  return [...cart, item];  // 新しい配列を返す
}
```

3ステップ:
1. コピーを作る
2. コピーを変更する
3. コピーを返す

これにより:
- 元のデータが壊れない
- 予期しない変更が起きない
- Action が Calculation に変わる場合がある

---

## 原則3: Defensive Copying（防御的コピー）

信頼できないコード（外部ライブラリ、API 境界）とデータをやり取りする時、入口と出口でコピーする。

```typescript
// 外部APIからデータを受け取る（入口）
function handleWebhook(rawPayload: unknown): Order {
  const data = structuredClone(rawPayload);  // 深いコピー
  return validateOrder(data);                // 内部で安全に使う
}

// 外部にデータを渡す（出口）
function getPublicProfile(user: User): PublicProfile {
  return structuredClone({                   // 深いコピーを渡す
    name: user.name,
    avatar: user.avatar,
  });
}
```

**Copy-on-Write vs Defensive Copying:**
- Copy-on-Write: 自分のコード内で使う（浅いコピーで十分）
- Defensive Copying: 信頼境界を越える時に使う（深いコピーが必要）

---

## 原則4: Stratified Design（層状設計）

コードを抽象度の層に分ける。各層は直下の層だけを呼ぶ。

```
┌─────────────────────────────┐
│  ビジネスルール              │  最上位: ドメイン固有のロジック
│  calcShippingFee()          │
├─────────────────────────────┤
│  ドメインオペレーション       │  中間: ドメイン概念の操作
│  addToCart(), removeItem()  │
├─────────────────────────────┤
│  汎用ユーティリティ          │  下位: 再利用可能な道具
│  map(), filter(), clone()   │
├─────────────────────────────┤
│  言語機能                    │  最下位: 言語が提供する機能
│  Array, Object, String      │
└─────────────────────────────┘
```

設計のヒント:
- **各関数の矢印が下向きだけになっているか？** → 上向き（下位が上位を呼ぶ）はNG
- **同じ層に異なる抽象度が混在していないか？** → `map()` と `calcShippingFee()` が同じ関数内にあったら分離
- **層が薄いほど良い** → 各層の関数は小さく、責務が明確

---

## 原則5: First-Class Abstractions（一級抽象化）

関数を値として扱い、パターンを抽象化する。

```typescript
// ❌ 繰り返しパターン
function cookAndEat(food: Food) { cook(food); eat(food); }
function washAndDry(dish: Dish) { wash(dish); dry(dish); }
function fillAndShip(order: Order) { fill(order); ship(order); }

// ✅ パターンを抽出（関数を引数に取る）
function doTwoSteps<T>(item: T, step1: (t: T) => void, step2: (t: T) => void) {
  step1(item);
  step2(item);
}
```

ただし **Straightforward 原則** に注意: 抽象化が理解を助けるなら導入する。3行の重複コードを抽象化するのは早すぎる。

---

## 原則6: Timeline Diagrams（タイムライン図）

複数の Action が同時に走る場合、タイムライン図で可視化する。

```
Timeline 1 (ユーザーA)      Timeline 2 (ユーザーB)
    │                           │
    ├── readCart()               │
    │                           ├── readCart()
    ├── addItem("milk")         │
    │                           ├── addItem("bread")
    ├── writeCart()              │
    │                           ├── writeCart()  ← ユーザーAの変更が消える！
    ▼                           ▼
```

**共有リソースへの Action が複数タイムラインから走ると、バグの温床になる。**

対策:
- 共有 mutable state を減らす（Calculations に置き換える）
- Action を直列化する（キュー、ロック）
- Copy-on-Write で共有を避ける

---

## 実践チェックリスト

コードを書く・レビューする時に:

- [ ] この関数は Action? Calculation? → **Calculation にできないか？**
- [ ] この Action の中に Calculation が埋まっていないか？ → **抽出**
- [ ] データを直接変更していないか？ → **Copy-on-Write**
- [ ] 外部境界でデータをコピーしているか？ → **Defensive Copying**
- [ ] 関数の抽象度が揃っているか？ → **Stratified Design**
- [ ] 共有状態を複数の Action が触っていないか？ → **Timeline 分析**
- [ ] 抽象化は理解を助けているか？ → **早すぎる抽象化ではないか**

---

## Rust での適用

本書の例は JavaScript だが、Rust にも自然に対応する:

| 概念 | Rust での表現 |
|------|-------------|
| Data | `struct`, `enum`（`#[derive(Clone)]`） |
| Calculations | `fn` + `&self`（`&mut` なし、I/O なし） |
| Actions | `async fn`, `fn` with `&mut`, I/O |
| Copy-on-Write | `.clone()` + 変更 + return |
| Defensive Copying | API 境界での `.clone()` / `.into()` |
| Stratified Design | モジュール階層、`pub`/`pub(crate)` |
| 型による安全性 | 所有権 + 借用 = 共有 mutable state の防止 |

Rust の所有権システムは、本書の多くの原則を**コンパイル時に強制**する。共有 mutable state は `&mut` の排他制約で自動的に防がれる。

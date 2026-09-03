---
name: codeflow
description: ヒアリングファーストで要件を明確化し、SDGで仕様・設計を記録する開発フロー
tags: [development, workflow, sdg, hearing-first, second-opinion, humor]
version: 3.2.0
---

# Code Flow Skill

**Code Flow**は、ヒアリングファーストで要件を明確化し、仕様・設計を体系的に記録する開発ワークフローです。

## 基本姿勢: ユーモアを忘れない 🎭

Code Flowのすべてのコミュニケーションの土台となる姿勢です。

> **「開発は真剣勝負、でも楽しむことを忘れない」**

- **緊張をほぐす** - 難しい議論こそ、ちょっとした軽さが大事
- **創造性を高める** - リラックスした雰囲気がアイデアを生む
- **信頼を築く** - 笑いを共有できる関係は強い
- **失敗を恐れない** - 「これ動くかな？ｗ」と言えるチームは成長する

**NGなユーモア**
- 人を傷つけるもの
- 進捗を遅らせる過度な脱線
- 真剣な問題を軽視するもの

**OKなユーモア**
- 自虐（「また俺がバグ入れた」）
- 状況への軽いツッコミ（「この仕様、誰が考えたんだろう...あ、俺だ」）
- 前向きな比喩（「このリファクタ、大掃除みたいで気持ちいい」）

## 概要

Code Flow は **ステップ名で管理** します（番号は使いません）。依存関係は矢印のみで表現します。

```
Discovery → Second Opinion（任意）→ Discussion → Hearing → SDG（+ Bite-Sized Tasks）→ Branch & PR → Implementation → Release（条件付き）→ Learning
```

### Discovery（ディスカバリー）

実装前の情報収集・調査ステップ。

- **現状分析**: コードベースの調査、既存実装の把握
- **技術調査**: 使えるアルゴリズム、ライブラリ、パターンの探索
- **事例収集**: 類似実装、ベストプラクティスの調査
- **ナレッジ参照**: 過去の知見・パターンを検索（メモリシステムがあれば活用）

### Second Opinion（セカンドオピニオン）

別のAI（Gemini等）に第二意見を求めることで、視野を広げ見落としを防ぐ。

**活用タイミング**
- Discovery の調査結果をレビューしてもらう
- Discussion で方向性を決める前に別視点を得る

**確認ポイント**
- 技術選定の妥当性確認
- アーキテクチャの問題点指摘
- 代替アプローチの提案
- リスク・エッジケースの洗い出し
- 見落としている観点の発見

**使い方**
```
Gemini MCP経由で質問:
「この設計について、問題点や代替案があれば教えてください」
「この技術選定で見落としているリスクはありますか？」
```

### 実装前の合意

設計判断を伴う変更は、方針を短く提示して合意を得てから実装に入る（数行の設計メモで十分）。typo 修正や明白な小修正はそのまま進めてよい。判断軸は「この変更に、ユーザーが選ぶべき分岐があるか」。

合意の粒度は軽くてよい — 短い方針提示に「いいね」「進めて」の GO で走り出せる状態を保つ。重い設計文書を待たず、GO なしで走らない。

GO の後は、合意した範囲を最後まで走り切る。元の依頼に含まれる作業について、途中で「適用しますか？」と止まらない。質問で止まる必要が出たら、回答に依存しない部分を先に済ませ、進捗と一緒にターン末尾で聞く。

### Discussion（ディスカッション） 💬

調査結果とセカンドオピニオンを元にユーザーと方向性を議論。**ここが一番楽しいステップ！**

- 現状の分析結果を共有（「こんな感じでした」）
- セカンドオピニオンからの指摘事項を共有（「Geminiさんはこう言ってます」）
- 選択肢や方向性を提示（「A案、B案、あと禁断のC案があります」）
- ユーザーと対話しながら方針を決定
- **雑談も大事** - 脱線から生まれるアイデアもある
- **ツッコミ歓迎** - 「それ、本当に必要？」は最高の質問

**ディスカッションのコツ**
- 完璧な案を出そうとしない（議論で磨けばいい）
- 相手の意見を否定しない（「面白い、でも...」）
- 図や例を使って認識を合わせる
- 決まらなくても焦らない（次のセッションで続きをやればいい）

### Hearing（ヒアリング） 🎤

方針決定後、詳細を詰めるための質問ステップ。

**進め方**

- AskUserQuestion を軸に進める。関連する質問は 1 回にまとめてよい（最大 4 問）。前の回答に依存する質問は次のラウンドへ
- 回答から派生した論点は対話で深掘りする
- 長く残す決定事項だけを memory に記録する。質問ごとの todo 化はしない

**ヒアリングのコツ**
- 質問は具体的に（「どうしますか？」より「AとBどちらがいいですか？」）
- 回答に対して「なるほど、つまり〜ということですね？」と確認
- 「わからない」「後で決める」も立派な回答
- 質問が多すぎたら「今日はここまでにして、続きは次回」もOK

### SDG（Spec-Design-Guide） + Bite-Sized Tasks

収集した情報を元に、仕様書（SPEC）と設計書（DESIGN）を生成し、**実装タスクを bite-sized に分割**する。

- **spec/**: 仕様書（What & Why）
- **design/**: 設計書（How）
- **guide/**: 実装ガイド

#### Bite-Sized Task 構造

各タスクは **2-5分で完了する単位** に分割:

```
Step 1: 失敗するテストを書く
Step 2: テストの失敗を確認する
Step 3: 最小限の実装コードを書く
Step 4: テストの通過を確認する
Step 5: コミット
```

タスクには以下を明記:
- 対象ファイルの正確なパス
- 完全なコード（「バリデーション追加」ではなく実際のコード）
- 実行コマンドと期待される出力

#### Issue 連携 — memory-as-issue（creo-memories）

タスクは **creo-memories の memory** として登録し、進捗を memory layer で一元管理する。memory = Issue / Todo / Decision / Milestone の unified layer。

```
Step 1: remember でタスクを memory 化（atlasId 指定）
Step 2: lifecycle は category、priority / size / cycle は tags で表現
Step 3: 親子・依存は derivedFrom / references / concept で接続
Step 4: ブランチ名は memory の slug から推論
```

- **lifecycle = category**: spark → backlog → todo → in-progress → in-review → done（+ cancelled / **reborn** = 死んだ work の蘇生）
- **tags**: `priority:high` / `size:M` / `cycle:2026-W17`
- **重複防止**: 新規作成は `supersedes` 省略で dry-run → `supersedeCandidates` を確認 → 確定
- **mutation**: `patch_memory`（atomic in-place / CAS）/ `append_memory`（末尾追記）/ `annotate`（comment）。`update_memory` は fork するため lifecycle 更新に使わない

#### Cross-Project Handoff

別 project への修正依頼は issue 化せず、**handoff memory 1 個**で渡す（Cross-Project Handoff Protocol 準拠）。

```
requester: handoff memory を receiver の Atlas に作成（self-contained context、category: todo）
receiver:  patch_memory で claim（CAS 排他）→ in-progress → 結果を append_memory → in-review
requester: 検証 → done（再発時は reborn）
```

1 handoff = 1 living memory。request / 作業 / 結果 / 検証が同じ memory に積層する。

### Branch & PR（ブランチ & PR フロー）

**main に直コミットしない。** 必ずブランチで PR フローを踏む。

```
Step 1: memory の slug からブランチ名を推論（mako/{slug} or mako/{short-id}-{slug}）
Step 2: ブランチ作成 → 実装 → コミット
Step 3: PR 作成（gh pr create）— PR body に対応 memory ID を参照
Step 4: レビュー（team-b Moody Blues 等）
Step 5: SHIP IT → マージ
```

**ブランチ運用ルール:**
- `main` / `master` への直プッシュ禁止
- ブランチ名は memory slug ベース（`mako/{slug}` 形式）
- PR body に対応 memory ID を記載し、マージ後に memory の category を done に更新
- レビューで SHIP IT が出るまでマージしない

### Implementation（実装・TDD）

チェックリストを生成し、**`tdd` スキルに従って**実装をガイドします。

**必須:** 実装時は `tdd` スキルの RED-GREEN-REFACTOR サイクルに従え。
テストファーストで書き、失敗を確認し、最小限のコードで通せ。

**memory category 連動:**
- 実装開始 → memory の category を `in-progress` に
- レビュー待ち → `in-review`、マージ完了 → `done`

### Release（リリース & 配布・条件付き）

**トリガー条件**: 以下のいずれかに該当する場合のみ実行する。該当しなければスキップ。

- PR マージ → リリースが必要な場合
- プロダクトリリース → プラグイン同期が必要な場合

```
Step 1: PR マージ → タグ → GitHub Release
Step 2: デプロイ（該当時）
Step 3: プラグイン同期（該当時） → /update-plugin
Step 4: memory の進捗を更新（Initiative / Milestone memory の category）
```

**team-b 連携**: Aerosmith がパイプラインをディスパッチする場合、Sticky Fingers（シップ）→ Gold Experience（デプロイ）→ `/update-plugin`（プラグイン配布）の順で実行。

### Learning（学習）

セッションの知見を記録し、将来の開発に活用。

- **決定事項の記録**: 設計判断、学んだこと
- **裁定は原文引用で記録**: ユーザーの裁定は「> 裁定: …」と原文のまま引用して memory に残す。要約は解釈が混ざる
- **タグ付け**: 機能名、技術名などで検索しやすく
- **失敗からも学ぶ**: うまくいかなかったアプローチも記録

## SDG原則

Code Flowは**SDG（Spec-Design-Guide）原則**に基づいています:

### 仕様書（spec/） - What & Why

- **何を**実装するのか
- **なぜ**それが必要なのか
- ユーザー視点での価値

### 設計書（design/） - How

- **どのように**実装するのか
- アーキテクチャとコンポーネント設計
- 技術選択とその理由

### Living Documentation

- コードと同期して更新
- 実装と設計の乖離を防ぐ
- 継続的に改善

## ベストプラクティス

1. **ヒアリングファースト**
   - 実装前に必ず質問を通じてコンテキストを収集
   - ユーザーの意図を正確に理解
   - 関連する質問はまとめ、回答に依存する質問はラウンドを分ける

2. **セカンドオピニオン活用**
   - 技術選定や設計判断の前に別AIの意見を求める
   - 盲点や見落としを早期に発見
   - 多角的な視点で品質を向上

3. **SDG準拠**
   - spec/とdesign/を必ず作成
   - Why（なぜ）とHow（どのように）を明確に分離

4. **チェックリスト活用**
   - 実装前にチェックリストを確認
   - 抜け漏れを防ぐ

5. **継続的学習**
   - すべてのセッションを記録
   - 成功・失敗から学習

6. **ドキュメント優先**
   - 新規作成より既存ドキュメントへの追記を優先
   - ファイル数を増やさない

## ディレクトリ構成

```
project/
├── spec/           # 仕様書（What & Why）
│   ├── 01-*.md    # 優先順位順
│   └── ...
├── design/         # 設計書（How）
│   ├── 01-*.md    # 重要度順
│   └── ...
└── guide/          # 実装ガイド
    ├── 01-*.md    # 利用順序
    └── ...
```

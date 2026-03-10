# Living Documentation - 生きたドキュメント原則

## 基本原則

ドキュメントは常に**現実とコードの写像**であり、リポジトリと共に進化する生きたテキストです。

## 生きたメモリーとして機能する

Living Documentationは、**AIエージェント（Claude）が信頼して活用できる生きたメモリー**として機能します。

### なぜ「生きたメモリー」なのか

**従来の静的ドキュメント**:

- ❌ 書いた時点で古くなる
- ❌ 実装と乖離していく
- ❌ 信頼できず、読まれなくなる
- ❌ 更新コストが高く放置される

**Living Documentation（生きたメモリー）**:

- ✅ コードと常に同期している
- ✅ 実装を正確に反映している
- ✅ AIエージェントが信頼して活用できる
- ✅ コード変更時に自然に更新される

### AIエージェントによる活用

AIエージェント（Claude）は、Living Documentationを以下のように活用します：

1. **コード変更前の理解**
   - specを読んで「なぜこの設計なのか」を理解
   - 設計思想を把握してから変更を行う

2. **設計意図の継承**
   - designを参照して実装方針を理解
   - 既存の設計パターンに沿った実装

3. **過去の判断から学習**
   - 変更履歴を読んで過去の意思決定を理解
   - 同じ理由で同じ間違いを繰り返さない

4. **自律的な作業**
   - ドキュメントを信頼して判断を下せる
   - 人間の介入なしに適切な実装が可能

### 信頼性の維持

Living Documentationが「信頼できる生きたメモリー」であり続けるために：

- 📅 **常に新鮮**: コード変更と同時に更新
- ✅ **正確性**: 実装と完全に一致
- 📝 **明確性**: AIエージェントが理解できる明確な記述
- 🔄 **進化**: プロジェクトの成長とともに成長

**結果**: AIエージェントは、ドキュメントを読むことで、プロジェクトの文脈を理解し、適切な判断を下し、品質の高いコードを書くことができる。

## 必須ルール

### 1. コード変更時は必ずドキュメントを更新

```
コード変更 → 該当するspec/designを確認 → 必要なら更新
```

**例**:

- `parser.rs`を修正 → `docs/design/02-parser-feature.md`を確認・更新
- データモデル変更 → `docs/spec/01-feature-name.md`を更新
- 新機能追加 → `docs/spec/NN-new-feature.md` を新規作成

### 2. ドキュメントとコードの不一致は技術的負債

以下は**バグ**として扱う:

- ドキュメントに書かれているが実装されていない機能
- 実装されているがドキュメントに記載されていない振る舞い
- 古い設計思想が残っているドキュメント

### 3. 変更のトレーサビリティ

メジャー変更のみ Changelog に記録。細かい修正は git に委ねる:

```markdown
## Changelog
- 2026-03-10: v2 — Supersedes VP-SPEC-000。要件ID体系を刷新
```

変更の経緯（なぜ変えたか）は creo-memories に `supersedes` パラメータで記録する。

## 実践ワークフロー

### プルリクエスト作成時

```bash
# 1. コード変更
vim src/parser/core.rs

# 2. 関連ドキュメントを確認
cat docs/design/02-parser-feature.md

# 3. ドキュメントが現実と一致しているか確認
# 不一致なら更新
vim docs/design/02-parser-feature.md

# 4. チェックリストを更新
# designの実装チェックリストにチェック

# 5. コミット（ドキュメント更新も含める）
git add src/parser/core.rs docs/design/02-parser-feature.md
git commit -m "パーサー改善とドキュメント更新"

# 6. PRの説明にドキュメント更新を記載
```

### コードレビュー時

レビュアーは以下を確認:

- [ ] コード変更に対応するドキュメント更新があるか
- [ ] specの哲学と実装が一致しているか
- [ ] designの設計と実装が一致しているか
- [ ] 実装チェックリストが更新されているか

### 定期的なドキュメント監査

週次/月次でドキュメントとコードの乖離をチェック:

```bash
# docs/spec/ と docs/design/ のファイルを順番に確認
# 各ドキュメントの Updated 日付と、対応コードの最終変更日を比較
ls -la docs/spec/ docs/design/
```

## ドキュメント駆動開発（DDD: Documentation Driven Development）

### 新機能実装の流れ

```
1. spec作成（Abstract → Motivation → Scope → Requirements）
   ↓
2. design作成（Abstract → Architecture → Data Model → Implementation）
   ↓
3. creo-memories に設計判断の経緯を記録
   ↓
4. 実装開始
   ↓
5. 要件（REQ-{NAME}-{NNN}）に対応するテストを書きながら実装
   ↓
6. 実装完了後、spec/designを見直し
   ↓
7. 乖離があれば修正（ドキュメントorコード）
```

### テスト駆動ドキュメント（TDD: Test Driven Documentation）

テストケースもドキュメントの一部:

```rust
/// REQ-PARSER-001: サービス名からイメージ名を推測
///
/// 仕様: service名が"postgres"、versionが"16"の場合、
///       imageは"postgres:16"となる
#[test]
fn test_infer_image_name_with_version() {
    // REQ-PARSER-001 に対応
    let result = infer_image_name("postgres", Some("16"));
    assert_eq!(result, "postgres:16");
}
```

## ドキュメントの品質指標

### 良いドキュメント

- ✅ コードを読まなくても理解できる
- ✅ なぜその設計なのか理由が書かれている
- ✅ 実装と100%一致している
- ✅ 最終更新日が新しい

### 悪いドキュメント

- ❌ 古い設計思想が残っている
- ❌ 実装と矛盾している
- ❌ 「TODO」が放置されている
- ❌ 最終更新が数ヶ月前

## 自動化

### CIでのチェック（TODO）

```yaml
# .github/workflows/docs-check.yml
- name: ドキュメント鮮度チェック
  run: |
    # 変更されたRustファイルに対応するdocs/spec/が更新されているかチェック
```

### pre-commit hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# 変更されたRustファイルをチェック
changed_rs_files=$(git diff --cached --name-only | grep '\.rs$')

if [ -n "$changed_rs_files" ]; then
    echo "⚠️  Rustファイルが変更されています"
    echo "📝 関連するdocs/spec/ドキュメントを確認・更新してください"
    echo ""
    echo "変更ファイル:"
    echo "$changed_rs_files"
fi
```

## コミットメッセージテンプレート

```
{変更内容の要約}

## ドキュメント更新（該当時のみ）
- docs/spec/NN-feature.md: 更新内容
- docs/design/NN-feature.md: 更新内容

Refs: #issue番号
```

コミットメッセージは簡潔に。詳細な理由・影響範囲は creo-memories に記録する。

## Claudeへの指示

→ 具体的な手順は `spec-design-guide/SKILL.md` の「コード変更時の必須手順」に従う。

---
description: Create or update spec/design documents
---

# Spec-Design-Guide

Create or update specification and design documentation.

## Document Types & Storage

| Type | Storage | Description |
|------|---------|-------------|
| **spec/** | Creo Memories only | What & Why (specifications, concepts, philosophy) |
| **design/** | Creo Memories only | How (architecture, data models, implementation) |
| **guide/** | Creo Memories + `docs/guide/` | Usage (how to use, best practices) |

- **spec/design**: Creo Memories のセマンティック検索でプロジェクト横断参照
- **guide**: Creo Memories（正）に保存 + リポジトリ `docs/guide/` に同期コピー。guide 作成・更新時は両方を更新する

## Principles

1. **Living Documentation** - Keep docs in sync with code
2. **Simplicity** - data, calculations, actions classification
3. **Straightforward** - Linear flow from input to output

## Usage

When creating or modifying code, ensure corresponding documentation is updated.
When creating or updating a guide, save to Creo Memories first, then write the same content to `docs/guide/`.

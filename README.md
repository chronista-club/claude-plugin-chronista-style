# Chronista Style Plugin

Claude Code plugin for Chronista development workflow.

## Features

- **Codeflow** - Hearing-first development workflow with SDG documentation
- **Spec-Design-Guide** - Living Documentation for specs and designs
- **FleetFlow** - KDL-based container orchestration

## Installation

```bash
# From official marketplace (coming soon)
claude plugin install chronista-style@claude-plugins-official

# Or from GitHub
/plugin marketplace add chronista-club/claude-plugins
claude plugin install chronista-style@chronista-plugins
```

## Commands

| Command | Description |
|---------|-------------|
| `/chronista:codeflow` | Start a hearing-first development session |
| `/chronista:sdg` | Create or update spec/design documents |
| `/chronista:hearing` | Begin a structured hearing session |

## Skills (Auto-triggered)

The following skills are automatically triggered based on context:

- **codeflow** - Activated during feature development
- **spec-design-guide** - Activated when creating/modifying documentation
- **fleetflow** - Activated when working with container configurations

## License

MIT

# Chronista Style Plugin

Claude Code plugin for Chronista development workflow.

## Features

- **Codeflow** - Hearing-first development workflow with SDG documentation
- **Spec-Design-Guide** - Living Documentation for specs and designs

## Related Plugins

| Plugin | Description |
|--------|-------------|
| [fleetflow](https://github.com/chronista-club/claude-plugin-fleetflow) | KDL-based container orchestration (MCP server) |

## Installation

```bash
# Add marketplace
claude plugin marketplace add chronista-club/claude-plugin-chronista-style

# Install plugin
claude plugin install chronista-style@chronista-style

# Optional: Install fleetflow (container orchestration)
claude plugin install fleetflow@chronista-style
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

## License

MIT

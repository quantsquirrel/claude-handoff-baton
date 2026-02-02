<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-02 | Updated: 2026-02-02 -->

# plugins

## Purpose

This directory contains the Claude Code plugin implementation for the Handoff project. Plugins are self-contained modules that extend Claude Code's functionality through the skill system. The `handoff` plugin here provides session context preservation capabilities.

## Key Files

| File | Description |
|------|-------------|
| `handoff/` | Main handoff plugin directory (see `handoff/AGENTS.md`) |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `handoff/` | Core handoff plugin with skill definition and configuration |

## For AI Agents

### Working In This Directory

- Each plugin lives in its own subdirectory
- Plugin configuration is in `plugin.json`
- Skill definitions are in markdown files (e.g., `handoff.md`)
- Follow Claude Code plugin specification for new plugins

### Plugin Structure Standard

```
plugins/
└── {plugin-name}/
    ├── plugin.json       # Plugin metadata and configuration
    └── {skill-name}.md   # Skill definition files (YAML frontmatter + markdown)
```

### Testing Requirements

- Verify plugin.json has valid JSON structure
- Ensure skill markdown files have proper YAML frontmatter
- Test that Claude Code can load and execute the skill

### Common Patterns

- Plugin names should be lowercase, hyphenated
- Version follows semver (MAJOR.MINOR.PATCH)
- Author information includes name and optional email

## Dependencies

### Internal

- `../SKILL.md` - Main skill definition reference
- `../hooks/` - Auto-handoff hook integration

### External

- Claude Code skill system for plugin loading
- Marketplace system for distribution (see `../.claude-plugin/`)

<!-- MANUAL: -->

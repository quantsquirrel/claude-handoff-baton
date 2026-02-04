<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-02 | Updated: 2026-02-02 -->

# .claude-plugin

## Purpose

Plugin marketplace configuration directory. Contains metadata for registering and distributing the Handoff plugin through the Claude Code plugin marketplace system. This enables automatic updates and discovery.

## Key Files

| File | Description |
|------|-------------|
| `marketplace.json` | Marketplace registration and plugin metadata |

## For AI Agents

### Working In This Directory

- `marketplace.json` is the primary configuration file
- This directory enables marketplace distribution
- Version must match `plugins/handoff/plugin.json` version

### marketplace.json Schema

```json
{
  "name": "handoff",
  "description": "Plugin description for marketplace listing",
  "version": "2.1.0",
  "owner": {
    "name": "author-name",
    "email": "contact@example.com"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "description": "Individual plugin description",
      "source": "./plugins/plugin-name",
      "version": "2.1.0",
      "author": { "name": "author-name" }
    }
  ]
}
```

### Version Management

When updating versions:

1. Update `marketplace.json` version
2. Update `plugins/handoff/plugin.json` version
3. Update `package.json` if exists
4. Create git tag for release

### Testing Requirements

- Validate JSON syntax: `cat marketplace.json | jq .`
- Verify version consistency across files
- Test marketplace registration if publishing

## Dependencies

### Internal

- `../plugins/handoff/plugin.json` - Must have matching version
- `../plugins/handoff/` - Source directory referenced in config

### External

- Claude Code marketplace system for plugin distribution
- Git tags for version releases

<!-- MANUAL: -->

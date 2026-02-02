<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-02 | Updated: 2026-02-02 -->

# handoff (Plugin)

## Purpose

Core handoff plugin implementation for Claude Code. Provides the `/handoff` skill with fast and slow modes for session context preservation. This is the primary deliverable of the Handoff project.

## Key Files

| File | Description |
|------|-------------|
| `plugin.json` | Plugin metadata: name, version, author, commands path |
| `handoff.md` | Skill definition with YAML frontmatter and usage documentation |

## For AI Agents

### Working In This Directory

- `plugin.json` defines plugin identity and entry point
- `handoff.md` is the actual skill implementation
- Changes here directly affect `/handoff` command behavior
- Test changes by running `/handoff fast` or `/handoff slow`

### plugin.json Structure

```json
{
  "name": "handoff",
  "version": "2.0.0",
  "description": "Session context handoff with fast/slow modes",
  "author": { "name": "quantsquirrel" },
  "commands": "./"
}
```

- `commands: "./"` means skill files are in this directory
- Version must match `../../.claude-plugin/marketplace.json`

### handoff.md Structure

The skill file uses YAML frontmatter + markdown:

```markdown
---
name: handoff
description: Session context handoff
triggers:
  - /handoff
---

# Skill Content
[Usage documentation and templates]
```

### Skill Modes

| Mode | Command | Output Size | Use Case |
|------|---------|-------------|----------|
| **fast** | `/handoff fast` | ~200 tokens | Quick checkpoint, context 70%+ |
| **slow** | `/handoff slow` | ~500 tokens | Full session handoff |
| **default** | `/handoff` | ~500 tokens | Alias for slow |

### Output Locations

| Mode | File Pattern | Example |
|------|-------------|---------|
| fast | `fast-YYYYMMDD-HHMMSS.md` | `fast-20260202-143022.md` |
| slow | `handoff-YYYYMMDD-HHMMSS.md` | `handoff-20260202-143022.md` |

Files are saved to `../../.claude/handoffs/`

### Testing Requirements

1. **Test fast mode:**
   ```bash
   /handoff fast "test topic"
   # Verify: File created, clipboard copied, ~200 tokens
   ```

2. **Test slow mode:**
   ```bash
   /handoff slow "test topic"
   # Verify: Full document, all sections, clipboard copied
   ```

3. **Test secret redaction:**
   - Include API_KEY in context
   - Verify it's replaced with `***REDACTED***`

4. **Test clipboard format:**
   - Paste clipboard content
   - Verify `<system-instruction>` block present
   - Verify `auto_execute="false"` attribute

### Common Patterns

#### Adding New Skill Mode

1. Add mode documentation to `handoff.md`
2. Define output template
3. Specify when to use (table in "When to Use" section)
4. Test the new mode

#### Updating Templates

Templates are defined in `handoff.md` as markdown code blocks. To update:

1. Find the relevant template section
2. Modify the markdown structure
3. Test that Claude generates correct output
4. Update examples in documentation

### Language Support

- Code and templates: English
- User-facing text: Bilingual (English + Korean)
- Comments in handoff.md: Korean supported per CLAUDE.md

## Dependencies

### Internal

- `../../SKILL.md` - Original detailed skill specification
- `../../hooks/auto-handoff.mjs` - Auto-suggests `/handoff` at 70%+ context
- `../../.claude/handoffs/` - Output directory for generated files

### External

- Claude Code skill system for command registration
- System clipboard (pbcopy/xclip) for copy functionality

<!-- MANUAL: -->

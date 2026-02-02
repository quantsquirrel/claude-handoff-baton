<!-- Generated: 2026-02-02 | Updated: 2026-02-02 -->

# AGENTS.md - Handoff Project Guide

**Project:** claude-handoff (Handoff)
**Version:** 1.3.0
**Purpose:** Session handoff tool for Claude Code - preserves context across sessions
**Language:** English (Core) + Korean (Documentation)
**License:** MIT

---

## Quick Start for Agents

**Working with Handoff?** Start here:

1. **Understand the purpose** - Read this file (you are here)
2. **Explore the structure** - Check the directory tree below
3. **Read SKILL.md** - Understand the 5-step workflow
4. **Review examples** - See real handoff documents
5. **Check active files** - See what needs work

---

## Project Purpose

Handoff is a Claude Code skill that captures and preserves session context when long-running work spans multiple sessions. It automates the process of documenting:

- **What was accomplished** - Completed tasks and decisions
- **What's pending** - Remaining work and blockers
- **What failed** - Approaches that didn't work (to avoid repeating)
- **How to resume** - Specific next steps for continuation

**Problem Solved:**
Without Handoff, resuming long projects means re-explaining context every session. With Handoff, context transfers automatically - complete with decisions, failed approaches, blockers, and next steps.

---

## Architecture Overview

### High-Level Flow

```
┌─────────────────────────────────────────────┐
│   Step 1: Context Gathering                 │
│   - Session analysis                        │
│   - Git status & file changes               │
│   - TODO items                              │
│   - Decisions & blockers                    │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│   Step 2: Secret Detection                  │
│   - Scan for API keys, passwords, tokens    │
│   - Redact sensitive data                   │
│   - Warn user if found                      │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│   Step 3: Template Population               │
│   - Fill handoff document sections          │
│   - Add file modifications                  │
│   - Include next steps & chain              │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│   Step 4: Clipboard Export                  │
│   - Create full document (.md)              │
│   - Generate 500-char summary               │
│   - Copy to clipboard (pbcopy/xclip)        │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│   Step 5: Quality Validation                │
│   - Calculate quality score (0-100)         │
│   - Check for TODOs, secrets, sections      │
│   - Warn if score < 70                      │
└─────────────────────────────────────────────┘
```

### Key Concepts

| Concept | Meaning | Example |
|---------|---------|---------|
| **Handoff Document** | Complete context capture for session continuity | `.claude/handoffs/handoff-20260201-143022.md` |
| **Quality Score** | Validation metric (0-100) for completeness | 87/100 = Good quality |
| **Handoff Chain** | Links between sessions for narrative continuity | Session 1 → Session 2 → Session 3 |
| **Secret Detection** | Pattern matching to prevent credential leaks | Redacts API keys, passwords, tokens |
| **Failed Approaches** | Documented unsuccessful attempts (learn from them) | "Tried X, failed because Y, learned Z" |
| **Auto-Handoff Hook** | Monitors context usage, suggests `/handoff` at 70%/80%/90% | Prevents context overflow |
| **Compact Recovery** | Auto-draft + lockfile for interrupted handoffs | Recoverable via `recover.mjs` |

---

## Directory Structure

```
claude-handoff/
├── AGENTS.md                          # You are here - Agent guidance
├── SKILL.md                           # Core skill definition & 5-step workflow
├── README.md                          # English documentation
├── README-ko.md                       # Korean documentation
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore patterns
│
├── assets/
│   └── handoff.jpeg                   # Project logo
│
├── docs/                              # Additional documentation
│   └── [future docs]
│
├── examples/
│   └── example-handoff.md             # Real handoff document example
│                                      # Shows all sections filled correctly
│
├── hooks/                             # Auto-handoff & recovery mechanisms
│   ├── auto-handoff.mjs               # Context monitoring (70%/80%/90% thresholds)
│   ├── constants.mjs                  # Threshold constants & messages
│   ├── lockfile.mjs                   # Lockfile management during generation
│   ├── recover.mjs                    # Recovery script for interrupted handoffs
│   └── install.sh                     # Easy hook installation
│
└── scripts/
    └── validate.sh                    # Handoff validation utility
```

---

## Key Files Reference

### Root Files

| File | Purpose | For Agents |
|------|---------|-----------|
| **SKILL.md** | Complete skill definition with 5-step workflow, templates, examples, best practices | Main spec - read first for implementation |
| **README.md** | User-facing documentation (English) | Keep updated for users |
| **README-ko.md** | Korean documentation for Korean users | Parallel to README.md |
| **LICENSE** | MIT License | Keep as-is |
| **.gitignore** | Git ignore patterns | Update if adding secrets/build artifacts |

### Subdirectories

#### `hooks/` - Auto-Handoff Mechanisms

| File | Purpose | Technology |
|------|---------|-----------|
| **auto-handoff.mjs** | Context monitoring hook - runs after large-output tools (Read, Grep, Bash, etc.) to suggest `/handoff` at 70%/80%/90% thresholds | ESM module, called via Claude Code PostToolUse hook |
| **constants.mjs** | Configuration: threshold values (0.70, 0.80, 0.90), cooldown (3 min), messages for each level | ESM module with export constants |
| **lockfile.mjs** | Manages `.generating.lock` file during handoff generation - prevents concurrent generation | ESM module for file operations |
| **recover.mjs** | Recovery script - lists draft files (`.draft-{timestamp}.json`) and detected interruptions | ESM module, run manually via `node recover.mjs` |
| **install.sh** | Bash script to add hook to `~/.claude/settings.json` | Bash, one-time setup |

**Hook Architecture:**
- Installed via `~/.claude/settings.json` PostToolUse hook
- Triggered on large-output tools: Read, Grep, Glob, Bash, WebFetch
- 3-minute cooldown between suggestions to prevent spam
- Checks if handoff created recently to skip duplicate suggestions
- Logs context usage to `.omc/logs/` if debug enabled

#### `examples/` - Reference Documentation

| File | Purpose |
|------|---------|
| **example-handoff.md** | Complete, real-world handoff document showing all sections properly filled - use as reference for quality |

#### `scripts/` - Utilities

| File | Purpose |
|------|---------|
| **validate.sh** | Validates handoff documents - checks for quality issues, TODO placeholders, secrets |

#### `assets/` - Static Resources

| File | Purpose |
|------|---------|
| **handoff.jpeg** | Project logo/banner used in README |

---

## Core Workflow (5 Steps)

Agents implementing `/handoff` command must follow this sequence:

### Step 1: Context Gathering

**Input:** Current session state
**Output:** Structured context data

**Collect:**
- Conversation summary (3-5 key points from session)
- Git status (modified, created, deleted files)
- Recent commits (last 5-10)
- TODO list from `.claude/tasks.json`
- Known blockers and issues
- Key architectural decisions made
- Failed approaches during session

**Implementation:**
```bash
git status --porcelain          # Get file changes
git log -5 --oneline            # Recent commits
git diff [files]                # Diffs for modified files
cat .claude/tasks.json          # TODO items
```

### Step 2: Secret Detection

**Input:** Collected context data
**Output:** Redacted data + warnings

**Patterns to detect:**
- API keys: `API_KEY`, `APIKEY`, `api-key`, `AKIA` (AWS)
- Secrets: `SECRET`, `secret_key`, `_SECRET`
- Passwords: `PASSWORD`, `passwd`, `pwd`
- Tokens: `TOKEN`, `auth_token`, `access_token`, `ghp_` (GitHub)
- Private keys: `-----BEGIN PRIVATE KEY`, `-----BEGIN RSA`
- Database URLs: `postgresql://user:pass@`, `mongodb+srv://`
- JWT secrets in code

**Action:** Replace with `***REDACTED***`, warn user if found

### Step 3: Template Population

**Input:** Redacted context
**Output:** Markdown handoff document

**Required sections:**
1. Metadata (Date, Duration, Directory)
2. Session Summary (3-5 sentences)
3. Handoff Chain (Previous, Next, Session Count)
4. Completed Tasks (checkboxes)
5. Pending Tasks (with status)
6. Key Decisions (Context + Choice + Rationale + Alternatives)
7. Failed Approaches (What + Why Failed + Learning)
8. Known Issues (Description + Workaround + Root Cause + Impact)
9. Files Modified (Created, Modified, Deleted)
10. Next Steps (Immediate, Short-term, Long-term)
11. How to Resume (Instructions)
12. Notes (Links, environment details)
13. Quality Score + Breakdown

**See SKILL.md for complete template.**

### Step 4: Clipboard Export

**Input:** Rendered handoff document
**Output:** Saved file + clipboard summary

**Actions:**
1. Save full document to `.claude/handoffs/handoff-YYYYMMDD-HHMMSS.md`
2. Generate 500-character summary:
   - Session count
   - Completed/Pending counts
   - Files modified count
   - Top blockers
   - First 2 Next Steps
   - Handoff path
3. Copy summary to clipboard:
   - macOS: `pbcopy`
   - Linux: `xclip` or `xsel`
4. Output instructions for next session

### Step 5: Quality Validation

**Input:** Generated handoff document
**Output:** Quality score (0-100) + feedback

**Scoring (5 criteria × 20 points each = 100):**

| Criterion | 20 Points | 0 Points |
|-----------|-----------|----------|
| **All sections filled** | Every section has content | Missing/empty sections |
| **No TODO placeholders** | No `TODO`, `TBD`, `[...]` | Placeholders exist |
| **No secrets detected** | Clean scan | Secrets found (redacted or not) |
| **Next Steps specific** | Concrete actions + time estimates | Vague ("fix", "improve") |
| **Files Modified listed** | All git changes documented | Missing files |

**Feedback by score:**
- 90-100: ✅ Excellent - ready to use
- 70-89: ⚠️ Good - could be better
- 50-69: ⚠️ WARNING - review missing sections
- 0-49: ❌ CRITICAL - incomplete, don't use

---

## Development Tasks

### For Feature Additions

When adding new features to Handoff:

1. **Update SKILL.md** - Document new parameters and behavior
2. **Update README.md** - Add to features list or usage examples
3. **Update constants.mjs** - If adding new thresholds or messages
4. **Add example** - Include new section in `examples/example-handoff.md`
5. **Update validation** - Extend `scripts/validate.sh` if needed
6. **Test recovery** - Verify lockfile/recover.mjs still works

### For Bug Fixes

1. **Identify scope** - Which file(s) affected? (hooks/, scripts/, SKILL.md?)
2. **Add test case** - Verify fix works
3. **Update docs** - Note in README if user-facing
4. **Check secrets** - Ensure fix doesn't create security holes
5. **Validate quality** - Generate test handoff, check quality score

### For Documentation Updates

1. **Korean translation** - Keep README-ko.md in sync with README.md
2. **Examples** - Add to `examples/example-handoff.md` if new pattern
3. **SKILL.md** - Most important - keep template & workflow current
4. **README** - User-facing guide, keep accurate

---

## Testing & Validation

### Manual Testing

```bash
# 1. Generate a test handoff
/handoff "test-feature"

# 2. Check output
cat .claude/handoffs/handoff-*.md | head -50

# 3. Validate quality
bash scripts/validate.sh .claude/handoffs/handoff-*.md

# 4. Verify clipboard (macOS)
pbpaste | head -20

# 5. Test recovery (if interrupted)
node hooks/recover.mjs
```

### Quality Checks

Before considering work complete:

- [ ] All 5 steps execute without errors
- [ ] Quality score >= 70 for test handoff
- [ ] No secrets detected in output
- [ ] Clipboard summary copies correctly
- [ ] Handoff chain links properly (if Session > 1)
- [ ] Next steps are specific (not vague)
- [ ] Files Modified section complete

### Recovery Testing

Test compact recovery mechanism:

```bash
# 1. Simulate interrupted generation (create lockfile)
touch .claude/handoffs/.generating.lock

# 2. Run recovery script
node hooks/recover.mjs

# 3. Verify it detects interruption
# Should show: "Detected interrupted generation"
```

---

## Common Patterns

### Adding New Secret Pattern

Edit `hooks/constants.mjs` or implementation:

```javascript
// Example: Add new pattern for custom API
const secretPatterns = [
  /API_KEY\s*=\s*[^\s]+/gi,
  /CUSTOM_SECRET\s*:\s*['"][^'"]+['"]/gi,  // Add this
];
```

### Customizing Quality Score

In SKILL.md Step 5 section, adjust criteria weights if needed:

Current: 5 criteria × 20 points
Alternative: 4 criteria × 25 points (if removing one)

### Extending Handoff Chain

To link more than 3 sessions:

```markdown
## Handoff Chain

- **Previous:** `.claude/handoffs/handoff-session-1.md`
- **Next:** (to be generated)
- **Session Count:** 4
- **Full Chain:** [Link to session 1] → [session 2] → [session 3] → [here]
```

### Korean Language Support

Handoff supports Korean output via `language: ko` config:

```bash
/handoff "주제" --language ko
```

All templates and messages work in both English and Korean.

---

## Dependencies

### Runtime Dependencies

| Dependency | Used In | Purpose |
|------------|---------|---------|
| Node.js | hooks/*.mjs, scripts/* | ESM module support, file operations |
| pbcopy (macOS) | auto-handoff.mjs | Clipboard copy on macOS |
| xclip/xsel (Linux) | auto-handoff.mjs | Clipboard copy on Linux |
| git | SKILL.md workflow | File changes, commit history |
| Claude Code | skill integration | Runs /handoff command |

### External Integrations

- **Claude Code skill system** - Registers `/handoff` command
- **Git repository** - Provides file changes, commit info
- **.claude/tasks.json** - Task list integration
- **~/.claude/settings.json** - Hook configuration
- **Clipboard** - System clipboard for context transfer

---

## Code Standards

### JavaScript/ESM Files

All hook files use ESM (`.mjs` extension):

```javascript
// Correct
export const THRESHOLD = 0.70;
import { constant } from './constants.mjs';

// Wrong
module.exports = { THRESHOLD };
const constant = require('./constants.mjs');
```

**Guidelines:**
- Use `export const` for constants
- Use `import` for dependencies
- Add JSDoc comments for public functions
- Use async/await for file operations
- Handle errors gracefully

### Markdown Files

- Use ATX-style headers (`#`, `##`, etc.)
- Code blocks with language: ` ```bash `, ` ```javascript `
- Tables for structured data
- Bullet points for lists
- Emphasis: `**bold**`, `*italic*`, `` `code` ``

### Configuration Files

- JSON in `hooks/constants.mjs` (exported)
- No `.env` files (security risk)
- Settings in `~/.claude/settings.json` for hooks

---

## Troubleshooting for Agents

### Issue: Clipboard not copying

**Cause:** pbcopy/xclip not available
**Fix:**
```bash
# macOS - should be built-in
which pbcopy

# Linux - install
sudo apt-get install xclip
```

### Issue: Quality score too low

**Causes:**
- Missing sections (fill all required sections)
- TODO placeholders (replace `[...]`, `TODO`, `TBD`)
- Secrets detected (review and redact)
- Vague next steps (add time estimates, specific actions)

**Fix:** Run validation, address each issue

### Issue: Handoff file already exists

**Cause:** Timestamp collision (rare)
**Fix:** Add milliseconds to filename or use custom path

### Issue: Git status shows nothing

**Cause:** Not in git repository or no changes
**Fix:**
```bash
git init  # Initialize if needed
# or add some changes first
```

### Issue: Recovery script finds no drafts

**Cause:** No interrupted handoffs detected
**Expected:** This is normal - recovery only needed if generation interrupted

---

## Performance Considerations

### Optimization Tips

| Issue | Solution |
|-------|----------|
| **Slow for large repos** | Limit diffs: `--maxDiffLines 30` |
| **Too many commits** | Limit commits: `--maxCommitsToShow 5` |
| **Clipboard slow** | Check pbcopy availability |
| **Large handoff file** | Remove optional sections |

### Typical Generation Times

- Small repo (<1k files): 2-3 seconds
- Medium repo (1k-10k files): 5-10 seconds
- Large repo (10k+ files): 15-30 seconds

---

## Integration Points

### Claude Code Hook System

Installed via PostToolUse hook:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Read|Grep|Glob|Bash|WebFetch",
      "hooks": [{
        "type": "command",
        "command": "node ~/.claude/skills/handoff/hooks/auto-handoff.mjs"
      }]
    }]
  }
}
```

### Task Integration

Reads from `.claude/tasks.json` for TODO items.

**Expected format:**
```json
{
  "tasks": [
    {"status": "completed", "text": "..."},
    {"status": "pending", "text": "..."}
  ]
}
```

### Git Integration

Uses standard git commands:
- `git status` - File changes
- `git log` - Commit history
- `git diff` - File diffs
- `git branch` - Branch name for auto-detection

---

## Security Notes

### Secret Detection

Handoff actively scans for and redacts:
- API keys (AWS `AKIA`, GitHub `ghp_`, etc.)
- Database URLs with credentials
- Private keys and certificates
- JWT secrets
- OAuth tokens

**Warning:** User is responsible for:
- Adding `.claude/handoffs/` to `.gitignore` if secrets leaked
- Not uploading handoff files to public repos
- Reviewing redacted content for safety

### Best Practices

1. **Never commit handoff files** - Add to `.gitignore`
2. **Review before sharing** - Check for secrets even with redaction
3. **Verify clipboard** - Confirm nothing sensitive copied
4. **Use securely** - Paste only in trusted environments

---

## Next Steps for Agents

### Short-term Tasks

- [ ] Improve error handling in `auto-handoff.mjs`
- [ ] Add more secret patterns to detection
- [ ] Enhance `validate.sh` with more checks
- [ ] Add unit tests for hooks

### Medium-term Tasks

- [ ] Encryption option for sensitive handoffs
- [ ] Database for handoff tracking/search
- [ ] Web UI for viewing handoff chain
- [ ] Batch handoff generation for multiple files

### Long-term Vision

- Integration with GitHub for PR context
- Team handoff (share across developers)
- AI-powered context analysis
- Automatic blockers detection

---

## Additional Resources

| Resource | Location | Purpose |
|----------|----------|---------|
| **Skill Definition** | `SKILL.md` | Core workflow & template |
| **User Guide** | `README.md` | How to use (English) |
| **Korean Guide** | `README-ko.md` | How to use (Korean) |
| **Example Handoff** | `examples/example-handoff.md` | Real-world reference |
| **License** | `LICENSE` | MIT License text |

---

## Communication

**For agents working on this project:**

- **Language:** English for code, documentation bilingual (EN/KO)
- **Code comments:** English
- **Docstrings:** English + Korean where useful
- **Issues/PRs:** Bilingual support appreciated

---

**Last Updated:** February 1, 2026
**Version:** 1.3.0
**Maintained by:** QuantSquirrel & Community

---

*This is a guide for AI agents working with the Handoff project. For user documentation, see README.md. For skill implementation details, see SKILL.md.*

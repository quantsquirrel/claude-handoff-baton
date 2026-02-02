<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-02 | Updated: 2026-02-02 -->

# assets

## Purpose

Static assets directory containing images, logos, and other binary resources used in documentation and branding for the Handoff project.

## Key Files

| File | Description |
|------|-------------|
| `handoff.jpeg` | Project logo/banner used in README documentation |

## For AI Agents

### Working In This Directory

- This directory contains binary files only
- Do not modify image files directly via code
- When adding new assets, use descriptive filenames
- Supported formats: JPEG, PNG, SVG for images

### Asset Naming Convention

- Use lowercase, hyphenated names: `project-logo.png`
- Include size suffix if multiple sizes: `logo-128x128.png`
- Use descriptive names that indicate purpose

### Usage in Documentation

Reference assets in markdown:

```markdown
![Handoff Logo](./assets/handoff.jpeg)
```

## Dependencies

### Internal

- Referenced by `../README.md` for project branding
- Referenced by `../README-ko.md` for Korean documentation

### External

None - standalone static files

<!-- MANUAL: -->

# Claude Code Statusline

Custom status line for Claude Code that displays model info, context window usage, rate limits, and git status directly in the terminal.

## What it displays

**Line 1:** Model name | rate limit usage (5h/7d with reset times) | context window progress bar with token counts (in/out)

**Line 2:** Current directory | git branch, upstream tracking, and last commit time

**Line 3:** Shortcut ticket link (if branch matches `sc-#####`) | staged/unstaged file counts with insertion/deletion stats

## Files

| File | Purpose |
|------|---------|
| `statusline-main.sh` | Entry point. Parses JSON from stdin, builds context and rate limit display, calls `statusline-git.sh`, prints output. |
| `statusline-git.sh` | Git helper. Outputs branch/upstream/sync info and staged/unstaged change stats. Detects Shortcut ticket IDs from branch names. |
| `colors.sh` | Shared ANSI color definitions used by both scripts. |

## Docs

Official documentation: https://code.claude.com/docs/en/statusline

## Setup

Add the following to your Claude Code `settings.json` (user or project level):

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/dotfiles/claude/statusline/statusline-main.sh"
  }
}
```

Claude Code pipes a JSON object to stdin containing session context (model, workspace, context window usage, rate limits). The script parses this with `jq` and renders the status line.

## Dependencies

- `jq` (JSON parsing)
- `git` (repository status)
- `date` (timestamp formatting)
- Bash 3.2+ (macOS default works)

## Context window colors

| Usage | Color |
|-------|-------|
| 0-49% | Green |
| 50-69% | Yellow |
| 70-84% | Orange |
| 85%+ | Red |

## Rate limit colors

| Usage | Color |
|-------|-------|
| 0-69% | Green |
| 70-84% | Yellow |
| 85%+ | Red |

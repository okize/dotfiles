# Claude Code Settings

Shared Claude Code settings, symlinked to `~/.claude/settings.json` by `bootstrap.sh`.

Machine-specific overrides (e.g. permissions) go in `~/.claude/settings.local.json`, which is **not** tracked here.

## Settings breakdown

### `env`

Environment variables injected into every Claude Code session.

- `AWS_REGION` — default AWS region
- `ENABLE_TOOL_SEARCH` — enables deferred tool loading for less common tools

### `sandbox`

Restricts what Claude Code can access on the filesystem. More specific rules take precedence over broader ones.

- `allowWrite: ["."]` — can write within the current project directory
- `denyWrite: ["/"]` — blocked from writing anywhere else
- `allowRead: ["."]` — can read within the current project directory
- `denyRead: ["~/"]` — blocked from reading the rest of your home directory

### `alwaysThinkingEnabled`

Extended thinking is always on, giving Claude more room to reason through problems before responding.

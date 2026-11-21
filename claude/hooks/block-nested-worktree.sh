#!/bin/sh
# PreToolUse hook for EnterWorktree.
# EnterWorktree with `name` creates a worktree inside the repo at .claude/worktrees/.
# Worktrees must be siblings of the repo (see AGENTS.md), so deny those calls.
# EnterWorktree with `path` enters an existing worktree and is allowed.

set -eu

command -v jq > /dev/null 2>&1 || exit 0

name="$(jq -r '.tool_input.name // empty')"
[ -n "$name" ] || exit 0

reason="Do not create worktrees inside the repo. Create a sibling worktree with \`wt switch --create $name --no-cd --format=json\`, then call EnterWorktree with the \"path\" from its output."

jq -n --arg reason "$reason" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'

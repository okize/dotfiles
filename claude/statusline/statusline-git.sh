#!/bin/bash

# Git status helper for statusline
# Arguments: $1 = current working directory
# Output (2 lines):
#   Line 1: branch (Upstream: origin/...) (synced Xd ago)
#   Line 2: [Shortcut: link |] Staged/Unstaged stats [or "No pending changes"]

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/colors.sh"

cwd="$1"

if [ ! -d "$cwd/.git" ] && ! git --no-optional-locks -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  echo "not a git repo"
  echo ""
  exit 0
fi

# Helper: all git commands quote $cwd to handle paths with spaces
run_git() { git --no-optional-locks -C "$cwd" "$@"; }

branch=$(run_git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Upstream detection: check exit code explicitly since a deleted remote branch
# can cause git to output literal "@{u}" instead of erroring on some versions
upstream=""
if run_git rev-parse --abbrev-ref --symbolic-full-name @{u} > /dev/null 2>&1; then
  upstream=$(run_git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
  # Guard against literal @{u} leaking through on resolution failure
  if [[ "$upstream" == *"@{u}"* ]]; then
    upstream=""
  fi
fi
upstream_display="${upstream:-None}"

# Last commit time -> relative sync status
last_commit_time=$(run_git log -1 --format=%ct 2>/dev/null)
diff_seconds=0
sync_color="$LIGHT_GREY"
if [ -n "$last_commit_time" ]; then
  diff_seconds=$(($(date +%s) - last_commit_time))
  if [ $diff_seconds -lt 60 ]; then
    sync_status="synced ${diff_seconds}s ago"
  elif [ $diff_seconds -lt 3600 ]; then
    sync_status="synced $((diff_seconds / 60))m ago"
  elif [ $diff_seconds -lt 86400 ]; then
    sync_status="synced $((diff_seconds / 3600))h ago"
  else
    sync_status="synced $((diff_seconds / 86400))d ago"
  fi
  if [ $diff_seconds -ge 86400 ]; then
    sync_color="$YELLOW"
  fi
else
  sync_status="no commits"
fi

# Parse porcelain once for file counts (replaces separate diff --name-only calls)
# Porcelain format: XY filename (X=staged status, Y=unstaged status)
#   Staged: first char is [MADRC]
#   Unstaged: second char is [MD]
#   Untracked: starts with ??
porcelain=$(run_git status --porcelain 2>/dev/null)

change_stats=""
if [ -n "$porcelain" ]; then
  staged_files=$(echo "$porcelain" | grep -c '^[MADRC]')
  unstaged_modified=$(echo "$porcelain" | grep -c '^.[MD]')
  untracked_files=$(echo "$porcelain" | grep -c '^??')
  unstaged_files=$((unstaged_modified + untracked_files))

  # Line-level insertion/deletion counts require shortstat (porcelain doesn't include them)
  # Only run the diff command when the relevant file count is > 0
  if [ "$staged_files" -gt 0 ]; then
    staged_diff=$(run_git diff --cached --shortstat 2>/dev/null)
    staged_ins=$(echo "$staged_diff" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
    staged_del=$(echo "$staged_diff" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+')
    change_stats="Staged: ${LIGHT_GREY}📄 ${staged_files}${RESET} • (${MUTED_GREEN}+${staged_ins:-0}${RESET}/${MUTED_RED}-${staged_del:-0}${RESET})"
  fi

  if [ "$unstaged_files" -gt 0 ]; then
    unstaged_diff=$(run_git diff --shortstat 2>/dev/null)
    unstaged_ins=$(echo "$unstaged_diff" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
    unstaged_del=$(echo "$unstaged_diff" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+')
    unstaged_part="Unstaged: ${LIGHT_GREY}📄 ${unstaged_files}${RESET} • (${MUTED_GREEN}+${unstaged_ins:-0}${RESET}/${MUTED_RED}-${unstaged_del:-0}${RESET})"
    if [ -n "$change_stats" ]; then
      change_stats="${change_stats} | ${unstaged_part}"
    else
      change_stats="${unstaged_part}"
    fi
  fi
fi

# Shortcut ticket detection from branch name (matches sc-##### pattern)
sc_number=$(echo "$branch" | grep -oE 'sc-[0-9]+' | head -1)
sc_url=""
if [ -n "$sc_number" ]; then
  ticket_num=$(echo "$sc_number" | grep -oE '[0-9]+')
  sc_url="https://app.shortcut.com/wistia-pde/story/${ticket_num}"
fi

# Line 1: branch + upstream + sync status
echo -e "${branch} (Upstream: ${upstream_display}) • ${sync_color}${sync_status}${RESET}"

# Line 2: [Shortcut |] change stats or "No pending changes"
# Uses printf '%b' for OSC 8 hyperlinks (echo -e unreliable for \e on macOS bash 3.2)
if [ -n "$sc_url" ] && [ -n "$change_stats" ]; then
  printf '%b\n' "Shortcut: ${LINK_BLUE}🔗 \033]8;;${sc_url}\a${sc_number}\033]8;;\a${RESET} | ${change_stats}"
elif [ -n "$sc_url" ]; then
  printf '%b\n' "Shortcut: ${LINK_BLUE}🔗 \033]8;;${sc_url}\a${sc_number}\033]8;;\a${RESET} | ${LIGHT_GREY}No pending changes${RESET}"
elif [ -n "$change_stats" ]; then
  echo -e "${change_stats}"
else
  echo -e "${LIGHT_GREY}No pending changes${RESET}"
fi

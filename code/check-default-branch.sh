#!/usr/bin/env bash
# Reports the default branch of every GitHub repo directly under a directory, and marks forks with [fork].
# Asks GitHub via gh, so the answer reflects the remote, not a stale local ref.
# Usage: check-default-branch.sh [dir]   (defaults to the current directory)
set -u

BASE_DIR="${1:-$PWD}"
if [ ! -d "$BASE_DIR" ]; then
  echo "Not a directory: $BASE_DIR" >&2
  exit 1
fi

for dir in "$BASE_DIR"/*/; do
  repo="${dir%/}"
  name="$(basename "$repo")"
  [ -e "$repo/.git" ] || continue

  # Resolve owner/repo from the origin remote
  slug=$(git -C "$repo" remote get-url origin 2>/dev/null \
    | sed -E 's#(git@github.com:|https://github.com/)##; s#(\.git)?/?$##')

  if [ -z "$slug" ]; then
    printf '%-40s NO REMOTE\n' "$name"
    continue
  fi

  # One API call returns both fields, e.g. "false main". Fork flag goes first because it is never empty.
  info=$(gh repo view "$slug" --json isFork,defaultBranchRef \
    --jq '(.isFork | tostring) + " " + (.defaultBranchRef.name // "")' 2>/dev/null)
  read -r is_fork branch <<< "$info"

  if [ -z "$branch" ]; then
    printf '%-40s ERROR (not on GitHub, no access, empty repo, or repo deleted)\n' "$name"
    continue
  fi

  suffix=""
  [ "$is_fork" = true ] && suffix=" [fork]"
  printf '%-40s %s%s\n' "$name" "$branch" "$suffix"
done

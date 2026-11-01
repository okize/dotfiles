#!/usr/bin/env bash
# Update every git repo directly under a directory: checkout main/master, pull --rebase.
# Usage: update-repos.sh [dir]   (defaults to the current directory)
set -u

BASE_DIR="${1:-$PWD}"
if [ ! -d "$BASE_DIR" ]; then
  echo "Not a directory: $BASE_DIR" >&2
  exit 1
fi

failed=()
skipped=()

for dir in "$BASE_DIR"/*/; do
  repo="${dir%/}"
  name="$(basename "$repo")"

  if [ ! -e "$repo/.git" ]; then
    skipped+=("$name (not a git repo)")
    continue
  fi

  # Linked worktrees have a .git file pointing at the parent repo; main checkouts have a .git directory.
  if [ -f "$repo/.git" ]; then
    skipped+=("$name (linked worktree)")
    continue
  fi

  if [ -n "$(git -C "$repo" status --porcelain)" ]; then
    skipped+=("$name (dirty working tree)")
    continue
  fi

  if git -C "$repo" show-ref --verify --quiet refs/heads/main; then
    branch=main
  elif git -C "$repo" show-ref --verify --quiet refs/heads/master; then
    branch=master
  else
    skipped+=("$name (no main or master branch)")
    continue
  fi

  echo "==> $name ($branch)"
  if ! git -C "$repo" checkout --quiet "$branch"; then
    failed+=("$name (checkout failed)")
    continue
  fi
  if ! git -C "$repo" pull --rebase; then
    failed+=("$name (pull --rebase failed)")
  fi
done

echo
if [ ${#skipped[@]} -gt 0 ]; then
  echo "Skipped:"
  printf '  %s\n' "${skipped[@]}"
fi
if [ ${#failed[@]} -gt 0 ]; then
  echo "Failed:"
  printf '  %s\n' "${failed[@]}"
  exit 1
fi
echo "Done."

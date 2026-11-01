#!/usr/bin/env bash
# Reports archived status for every git repo under the current directory.
set -u

for dir in */; do
  [ -e "$dir/.git" ] || continue
  name=${dir%/}

  # Resolve owner/repo from the origin remote
  repo=$(git -C "$dir" remote get-url origin 2>/dev/null \
    | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')

  if [ -z "$repo" ]; then
    printf '%-40s NO REMOTE\n' "$name"
    continue
  fi

  archived=$(gh repo view "$repo" --json isArchived --jq '.isArchived' 2>/dev/null)

  case "$archived" in
    true)  printf '%-40s ARCHIVED\n' "$name" ;;
    false) printf '%-40s active\n'   "$name" ;;
    *)     printf '%-40s ERROR (no access or repo deleted)\n' "$name" ;;
  esac
done

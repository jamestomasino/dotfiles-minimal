#!/bin/sh

# Resolve script directory (trailing slash for safe path matching)
DIR="$(cd "$(dirname "$0")" && pwd)/"

# Parse flags
DESKTOP=0
while [ $# -gt 0 ]; do
  case "$1" in
    --desktop) DESKTOP=1; shift ;;
    *) shift ;;
  esac
done

# Desktop-only entries (local machines only)
DESKTOP_ONLY="kitty imwheel"

# Check if a path should be skipped (desktop-only, when --desktop not set)
should_skip() {
  if [ "$DESKTOP" -eq 1 ]; then
    return 1
  fi
  for d in $DESKTOP_ONLY; do
    case "$1" in
      "${d}"/*) return 0 ;;
    esac
  done
  return 1
}

# Collect all files, excluding .git and management files.
find . -not -path ./.git -not -path './.git/*' -type f | while IFS= read -r file; do
  relpath="${file#./}"
  base="$(basename "$relpath")"

  # Skip management files
  case "$base" in
    .gitignore|install.sh|uninstall.sh|README.md|PLAN.md) continue ;;
  esac

  # Skip desktop-only paths
  should_skip "$relpath" && continue

  # Create parent directory if needed
  parent="$(dirname "${HOME}/${relpath}")"
  mkdir -p "$parent"

  # Link file (skip if target already exists)
  if [ -e "${HOME}/${relpath}" ]; then
    printf 'File Exists, Skipping: %s\n' "${HOME}/${relpath}"
  else
    ln -sf "${DIR}${relpath}" "${HOME}/${relpath}"
    printf 'Linking: %s/%s\n' "${DIR}" "${relpath}"
  fi
done

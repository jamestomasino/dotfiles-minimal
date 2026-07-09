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

# Walk the same files that install.sh would link, and remove symlinks
# in HOME that point into this repo.
find . -not -path ./.git -not -path './.git/*' -type f | while IFS= read -r file; do
  relpath="${file#./}"
  base="$(basename "$relpath")"

  # Skip management files
  case "$base" in
    .gitignore|install.sh|uninstall.sh|README.md|PLAN.md) continue ;;
  esac

  # Skip desktop-only paths
  should_skip "$relpath" && continue

  # Only remove if it is a symlink pointing into this repo
  if [ -L "${HOME}/${relpath}" ]; then
    target="$(readlink "${HOME}/${relpath}")"
    # Strip trailing slash for matching (readlink normalizes paths)
    basedir="${DIR%?}"
    case "$target" in
      "${basedir}"/*|"${basedir}")
        rm -f "${HOME}/${relpath}"
        printf 'Removing: %s\n' "${HOME}/${relpath}"
        ;;
    esac
  fi
done

# Clean up empty directories left behind (depth-first)
find "${HOME}" -depth -type d -empty -exec rmdir {} \; 2>/dev/null

# shellcheck shell=bash
# Minimal .bashrc — sources .profile as the master config.
# Only bash-specific additions live here.

# Source master profile (with double-source guard)
if [ -f "$HOME/.profile" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.profile"
fi

# --- Bash-specific settings ---

# vi keybindings
set -o vi

# Bash completion (system)
if [ -f /usr/share/bash-completion/bash_completion ]; then
  # shellcheck disable=SC1091
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  # shellcheck disable=SC1091
  . /etc/bash_completion
fi

# Deno completion
if [ -f "$HOME/.local/share/bash-completion/completions/deno.bash" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.local/share/bash-completion/completions/deno.bash"
fi

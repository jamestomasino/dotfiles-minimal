# history
export HISTFILE="$HOME/.history"
export HISTTIMEFORMAT="%F %T "
export HISTCONTRAL=ignoredups
export HISTFILESIZE=100000
export HISTSIZE=100000
export HISTIGNORE="clear:keybase*:bssh:exit"

# colors
export LSCOLORS=gxfxcxdxbxggedabagacad
export CLICOLOR=1
export TERM="screen-256color"
export COLORTERM=truecolor
LESS_TERMCAP_mb=$(tput bold; tput setaf 2); export LESS_TERMCAP_mb
LESS_TERMCAP_md=$(tput bold; tput setaf 4); export LESS_TERMCAP_md
LESS_TERMCAP_me=$(tput sgr0); export LESS_TERMCAP_me
LESS_TERMCAP_so=$(tput bold; tput setaf 7; tput setab 4); export LESS_TERMCAP_so
LESS_TERMCAP_se=$(tput rmso; tput sgr0); export LESS_TERMCAP_se
LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 9); export LESS_TERMCAP_us
LESS_TERMCAP_ue=$(tput rmul; tput sgr0); export LESS_TERMCAP_ue
LESS_TERMCAP_mr=$(tput rev); export LESS_TERMCAP_mr
LESS_TERMCAP_mh=$(tput dim); export LESS_TERMCAP_mh
LESS_TERMCAP_ZV=$(tput rsubm); export LESS_TERMCAP_ZV
LESS_TERMCAP_ZW=$(tput rsupm); export LESS_TERMCAP_ZW
export GROFF_NO_SGR=1;

# search
if command -v ag > /dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git --ignore .sass-cache --ignore npm_modules -g ""'
fi

# fzf
if command -v fzf > /dev/null 2>&1; then
  export FZF_DEFAULT_OPTS=""
  _gen_fzf_default_opts() {
    # Base16 Tomorrow Night
    color00='#1d1f21'
    color01='#282a2e'
    color04='#b4b7b4'
    color06='#e0e0e0'
    color0A='#f0c674'
    color0C='#8abeb7'
    color0D='#81a2be'
    export FZF_DEFAULT_OPTS="
    --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D
    --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C
    --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D
    "
  }
  _gen_fzf_default_opts
  if [ -f ~/.fzf.bash ]; then
    # shellcheck source=/dev/null
    . ~/.fzf.bash
  fi
fi

# web
export LYNX_CFG="$HOME/.config/lynx/config"
export CURL_HOME="$HOME/.config/curl"
export WWW_HOME="gopher://gopher.black"

# sync
export SYNCTHING_PATH="$HOME/.syncthing"
export SSH_ENV="$HOME/.ssh/environment"
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

export SSH_KEY_LOCATIONS="${HOME}/.ssh/ ${HOME}/keys/personal/ssh/ ${HOME}/keys/work/ssh/"

# personal app storage paths
export TODO="$SYNCTHING_PATH/todo/personal.txt"
export NOTE_DIR="$SYNCTHING_PATH/notes"
export CONTACTS_DIR="$SYNCTHING_PATH/contacts"
export TRACK_DIR="$SYNCTHING_PATH/track"
export AUDIOBOOKS="${HOME}/pCloudDrive/Audiobooks/"
export STATIONS="${SYNCTHING_PATH}/music/stations.txt"

# system
export TZ=":Etc/UTC"
export LANG="en_US.UTF-8"
export LC_TIME="en_GB.UTF-8"
export ZPOOL_VDEV_NAME_PATH=YES

# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# XDG Path Fixes
export LESSHISTFILE="${XDG_CONFIG_HOME}/less/history"
export LESSKEY="${XDG_CONFIG_HOME}/less/keys"
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/config
export NPM_CONFIG_CACHE=$XDG_CACHE_HOME/npm
export CALCHISTFILE=$XDG_DATA_HOME/calc_history
export DOTREMINDERS=$XDG_CONFIG_HOME/remind/reminders
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
alias ag='ag --path-to-ignore $XDG_CONFIG_HOME/ag/ignore'

# GPG
GPG_TTY=$(tty)
export GPG_TTY

# vim
export EDITOR="vim"
set -o vi

# less settings
export PAGER=less

# umask liberal
umask 0022

# Load functions
if [ -d "${HOME}/.functions" ]; then
  for f in "${HOME}/.functions/"*; do
    # shellcheck source=/dev/null
    . "$f"
  done
fi

# basic shell aliases
if command -v colorls > /dev/null 2>&1; then
  alias ls='colorls -G'
  unset LSCOLORS
else
  export LSCOLORS=gxfxcxdxbxggedabagacad
  alias ls='ls --color'
fi

# Command overwrites
alias mkdir='mkdir -p'
alias grep='grep --color=auto'
alias lynx='lynx -display_charset=utf8 --lss=/dev/null'
alias tmux='tmux -u2 -f "$XDG_CONFIG_HOME"/tmux/tmux.conf'
alias tmate='tmate -u2 -f "$XDG_CONFIG_HOME"/tmux/tmux.conf'
alias ag="ag --color-path 35 --color-match '1;35' --color-line-number 32"
alias newsboat='newsboat -C "$XDG_CONFIG_HOME"/newsboat/config -u "$XDG_CONFIG_HOME"/newsboat/urls -c "$XDG_CACHE_HOME"/newsboat.db'
# Directory Helpers
alias lsd='ls -Gl | grep "^d"'
alias cd..="cd .."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
# Time Aliases
alias utc='date -u +%H:%M:%S'
alias beat='echo "x = ($(date +%s) + 3600) % 86400; scale=3; x / 86.4" | bc'
alias beatTAI='echo "x = $(date +%s) % 86400; scale=3; x / 86.4" | bc'
alias mil='echo "x = $(date +%s) % 86400; scale=3; x / 86400" | bc'
alias julian='echo "x = $(date +%s); scale=5; x / 86400 + 2440587.5" | bc'
alias getmusic="yt-dlp -x --audio-quality 0 --audio-format mp3"
alias getplaylist="yt-dlp -x --audio-quality 0 --audio-format mp3 --yes-playlist"
# General Helpers
alias vimr='vim -u NONE -U NONE -i NONE'
alias wiki="vim -c VimwikiIndex"
alias gs="git status"
alias t='tmux attach || tmux new'
alias mosh="export LC_ALL=\"en_US.UTF8\" && mosh"
alias proxy="ssh -D 1337 -q -C -N"

# PROMPT COMMANDS
PROMPT_COMMAND="history -a; history -r; $PROMPT_COMMAND"

# use color in prompt if not dash. Color works there, but screws up line wrapping
USER=$(id -un)
HOSTNAME=$(uname -n)
# true shell (TS) name
TS=$(ps -cp "$$" -o command="" 2>/dev/null)
if [ -z "$TS" ] || [ "$TS" = "" ] || [ "$TS" = "dash" ] || [ "$TS" = "sh" ]; then
  # dash/sh can't render colors properly in the prompt without breaking readline
  PS1="[${HOSTNAME}] " # [hostname]
  PS1=${PS1}'$(basename $(pwd)) ' # workingdir
  PS1=${PS1}"-> " # ->
else
  DIRECTORY_COLOR="\001$(tput setaf 12)\002";
  PIPE_COLOR="\001$(tput setaf 241)\002";
  PROMPT_COLOR="\001$(tput setaf 196)\002";
  HOST_COLOR="\001$(tput setaf 245)\002"
  RESET_COLOR="\001$(tput sgr0)\002"
  PS1="${HOST_COLOR}${HOSTNAME}" # [hostname]
  PS1=${PS1}"${PIPE_COLOR}|" # [hostname]
  PS1=${PS1}"${DIRECTORY_COLOR}\w" # workingdir
  PS1=${PS1}"\n$PROMPT_COLOR->$RESET_COLOR " # ->
  unset DIRECTORY_COLOR PROMPT_COLOR HOST_COLO RESET_COLOR
fi
export PS1

# system path
path() { [ -d "$1" ] && PATH="${PATH}${PATH:+:}${1}"; }
PATH=/bin
path "/sbin"
path "/usr/bin"
path "/usr/sbin"
path "/usr/games"
path "/usr/pkg/bin"
path "/usr/local/sbin"
path "/usr/local/bin"
path "/usr/X11/bin"
path "/opt/local/bin"
path "/opt/local/sbin"
path "/snap/bin"
path "/tilde/bin"
path "${HOME}/bin"
path "${HOME}/.yarn/bin"
path "${HOME}/.npm-packages/bin"
path "${HOME}/.config/yarn/global/node_modules/.bin"
path "${HOME}/.node/bin"
path "${HOME}/.cargo/bin"
path "${HOME}/.local/bin"
path "${HOME}/.fzf/bin"
path "${HOME}/go/bin"
path "/var/lib/flatpak/exports/share"
path "${HOME}/.local/share/flatpak/exports/share"

# javascript
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
if command -v node > /dev/null 2>&1; then
  NPM_PACKAGES="${HOME}/.npm-packages"
  export NODE_PATH="/usr/local/lib/jsctags:/usr/local/lib/node:${HOME}/.yarn/bin:/usr/bin/npm"
  export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
fi

# deno
if [ -d "${HOME}/.deno" ]; then
  export DENO_INSTALL="${HOME}/.deno"
  path "$DENO_INSTALL/bin"
fi

# perl 5
if [ -d "${HOME}/perl5" ]; then
  path "${HOME}/perl5/bin"
  export PERL5LIB="${HOME}/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
  export PERL_LOCAL_LIB_ROOT="${HOME}/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
  export PERL_MB_OPT="--install_base '${HOME}/perl5'"
  export PERL_MM_OPT="INSTALL_BASE=${HOME}/perl5"
  if [ -f "$HOME/perl5/perlbrew/etc/bashrc" ]; then
    # shellcheck source=/dev/null
    . "$HOME/perl5/perlbrew/etc/bashrc"
  fi
fi

# rust
if [ -f "$HOME/.cargo" ]; then
  . "$HOME/.cargo/env"
fi

# android sdk
if [ -d "${HOME}/sdk/" ]; then
  export ANDROID_HOME="/usr/lib/android-sdk"
  path "${ANDROID_HOME}/tools"
  path "${ANDROID_HOME}/tools/bin"
  path "${ANDROID_HOME}/platform-tools"
  path "${ANDROID_HOME}/build-tools/25.0.3"
fi

# Load local system overrides
if [ -f "$HOME/.profile_local" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.profile_local"
fi

. "$HOME/.cargo/env"

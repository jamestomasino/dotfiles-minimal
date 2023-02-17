# history
export HISTFILE="$HOME/.history"
export HISTCONTRAL=ignoredups
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTIGNORE="clear:keybase*:lssh"

# colors
export LSCOLORS=gxfxcxdxbxggedabagacad
export CLICOLOR=1
export TERM=screen-256color
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
export MPLAYER_HOME=$XDG_CONFIG_HOME/mplayer
export LESSHISTFILE="${XDG_CONFIG_HOME}/less/history"
export LESSKEY="${XDG_CONFIG_HOME}/less/keys"
export LPASS_HOME=$XDG_CONFIG_HOME/lpass
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/config
export NPM_CONFIG_CACHE=$XDG_CACHE_HOME/npm
export CALCHISTFILE=$XDG_DATA_HOME/calc_history
export DOTREMINDERS=$XDG_CONFIG_HOME/remind/reminders

# vim
export EDITOR="vim"
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

# less settings
export PAGER=less

# umask liberal
umask 0022

# use vim on the command line
set -o vi

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

alias lsd='ls -Gl | grep "^d"'
alias cd..="cd .."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias grep='grep --color=auto'
alias mkdir='mkdir -p'
alias lynx='lynx -display_charset=utf8 --lss=/dev/null'
alias newsboat='newsboat -C "$XDG_CONFIG_HOME"/newsboat/config -u "$XDG_CONFIG_HOME"/newsboat/urls -c "$XDG_CACHE_HOME"/newsboat.db'
alias utc='date -u +%H:%M:%S'
alias vimr='vim -u NONE -U NONE -i NONE'
alias gs="git status"
alias ag="ag --color-path 35 --color-match '1;35' --color-line-number 32"
alias tmux='tmux -u2 -f "$XDG_CONFIG_HOME"/tmux/tmux.conf'
alias t='tmux attach || tmux new'
alias beat='echo "x = ($(date +%s) + 3600) % 86400; scale=3; x / 86.4" | bc'
alias beatTAI='echo "x = $(date +%s) % 86400; scale=3; x / 86.4" | bc'
alias mil='echo "x = $(date +%s) % 86400; scale=3; x / 86400" | bc'
alias julian='echo "x = $(date +%s); scale=5; x / 86400 + 2440587.5" | bc'
alias anonradio='mplayer -quiet http://anonradio.net:8000/anonradio'
alias tilderadio='mplayer -quiet https://azuracast.tilderadio.org/radio/8000/320k.ogg'
alias sleepbot='mplayer -quiet -playlist "http://www.sleepbot.com/ambience/cgi/listen.cgi/listen.pls"'
alias wrti="mplayer -quiet http://playerservices.streamtheworld.com/api/livestream-redirect/WRTI_CLASSICAL.mp3"
alias getmusic="youtube-dl -x --audio-quality 0 --audio-format mp3"
alias getplaylist="youtube-dl -x --audio-quality 0 --audio-format mp3 --yes-playlist"
alias wiki="vim -c VimwikiIndex"
alias mosh="export LC_ALL=\"en_US.UTF8\" && mosh"

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
path "${HOME}/.local/bin"
path "${HOME}/.fzf/bin"
path "${HOME}/go/bin"
path "/var/lib/flatpak/exports/share"
path "${HOME}/.local/share/flatpak/exports/share"

# javascript
export NVM_DIR="$HOME/.local/share/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
if command -v node > /dev/null 2>&1; then
  NPM_PACKAGES="${HOME}/.npm-packages"
  export NODE_PATH="/usr/local/lib/jsctags:/usr/local/lib/node:${HOME}/.yarn/bin:/usr/bin/npm"
  export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
fi

# deno
export DENO_INSTALL="/home/tomasino/.deno"
path "$DENO_INSTALL/bin"


# perl 5
if [ -d "${HOME}/perl5" ]; then
  PATH=${PATH}:${HOME}/perl5/bin
  export PERL5LIB="/home/tomasino/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
  export PERL_LOCAL_LIB_ROOT="/home/tomasino/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
  export PERL_MB_OPT="--install_base 'home/tomasino/perl5'"
  export PERL_MM_OPT="INSTALL_BASE=/home/tomasino/perl5"
  if [ -f "$HOME/perl5/perlbrew/etc/bashrc" ]; then
    # shellcheck source=/dev/null
    . "$HOME/perl5/perlbrew/etc/bashrc"
  fi
fi

# android sdk
if [ -d "${HOME}/sdk/" ]; then
  export ANDROID_HOME="/usr/lib/android-sdk"
  PATH=${PATH}:${ANDROID_HOME}/tools
  PATH=${PATH}:${ANDROID_HOME}/tools/bin
  PATH=${PATH}:${ANDROID_HOME}/platform-tools
  PATH=${PATH}:${ANDROID_HOME}/build-tools/25.0.3
fi

# Load local system overrides
if [ -f "$HOME/.profile_local" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.profile_local"
fi


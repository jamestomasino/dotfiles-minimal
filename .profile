###############################################################################
################################### environment ###############################
###############################################################################

# vars
if command -v nvim > /dev/null 2>&1; then
  export EDITOR="nvim"
  alias vim='nvim'
else
  export EDITOR="vim"
  export VIMINIT='source "$XDG_CONFIG_HOME/vim/vimrc"'
fi

export HISTFILE="$HOME/.history"
export HISTCONTRAL=ignoredups
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTIGNORE="clear:keybase*:lssh"

export LSCOLORS=gxfxcxdxbxggedabagacad
export CLICOLOR=1

if command -v ag > /dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git --ignore .sass-cache --ignore npm_modules -g ""'
fi
export FZF_DEFAULT_OPTS=""
export LYNX_CFG="$HOME/.config/lynx/config"
export CURL_HOME="$HOME/.config/curl"
export WWW_HOME="gopher://gopher.black"

# path vars
export SYNCTHING_PATH="$HOME/.syncthing"
export SSH_ENV="$HOME/.ssh/environment"
export ANDROID_HOME="$HOME/sdk"

# lastpass
export LPASS_HOME="$HOME/.lpass"
export LPASS_DISABLE_PINENTRY=0
export SSH_KEY_LOCATIONS="${HOME}/.ssh/ ${HOME}/.spideroak/Documents/Keys/personal/ssh/ ${HOME}/.spideroak/Documents/Keys/work/ssh/"

# personal app storage paths
export TODO="$SYNCTHING_PATH/todo/personal.txt"
export NOTE_DIR="$SYNCTHING_PATH/notes"
export CONTACTS_DIR="$SYNCTHING_PATH/contacts"
export TRACK_DIR="$SYNCTHING_PATH/track"

# system
export TZ="Atlantic/Reykjavik"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

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

# colors
export TERM=screen-256color

# less and man colors
LESS_TERMCAP_mb=$(tput bold; tput setaf 2 0 0); export LESS_TERMCAP_mb
LESS_TERMCAP_md=$(tput bold; tput setaf 6 0 0); export LESS_TERMCAP_md
LESS_TERMCAP_me=$(tput sgr0); export LESS_TERMCAP_me
LESS_TERMCAP_so=$(tput bold; tput setaf 3 0 0; tput setab 4 0 0); export LESS_TERMCAP_so
LESS_TERMCAP_se=$(tput rmso; tput sgr0); export LESS_TERMCAP_se
LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7 0 0); export LESS_TERMCAP_us
LESS_TERMCAP_ue=$(tput rmul; tput sgr0); export LESS_TERMCAP_ue
LESS_TERMCAP_mr=$(tput rev); export LESS_TERMCAP_mr
LESS_TERMCAP_mh=$(tput dim); export LESS_TERMCAP_mh
LESS_TERMCAP_ZV=$(tput rsubm); export LESS_TERMCAP_ZV
LESS_TERMCAP_ZW=$(tput rsupm); export LESS_TERMCAP_ZW
export GROFF_NO_SGR=1;

# Base16 Tomorrow Night
_gen_fzf_default_opts() {
  color00='#1d1f21'
  color01='#282a2e'
#  color02='#373b41'
#  color03='#969896'
  color04='#b4b7b4'
#  color05='#c5c8c6'
  color06='#e0e0e0'
#  color07='#ffffff'
#  color08='#cc6666'
#  color09='#de935f'
  color0A='#f0c674'
#  color0B='#b5bd68'
  color0C='#8abeb7'
  color0D='#81a2be'
#  color0E='#b294bb'
#  color0F='#a3685a'

  export FZF_DEFAULT_OPTS="
  --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D
  --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C
  --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D
  "
}
_gen_fzf_default_opts

# less settings
export PAGER=less

# PROMPT COMMANDS
PROMPT_COMMAND="history -a; history -r; $PROMPT_COMMAND"

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
  alias ls='ls --color'
fi
alias lsd='ls -Gl | grep "^d"'
alias cd..="cd .."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# aliases to default commands with certain switches
alias grep='grep --color=auto'
alias mkdir='mkdir -p'

# utils
alias lynx='lynx -display_charset=utf8 --lss=/dev/null'
alias newsboat='newsboat -C "$XDG_CONFIG_HOME"/newsboat/config -u "$XDG_CONFIG_HOME"/newsboat/urls -c "$XDG_CACHE_HOME"/newsboat.db'
alias utc='date -u +%H:%M:%S'

# vim
alias vimr='vim -u DEFAULTS -U NONE -i NONE'

# git
alias gs="git status"

# tmux
alias tmux='tmux -u2 -f "$XDG_CONFIG_HOME"/tmux/tmux.conf'
alias t='tmux attach || tmux new'

alias beat='echo "x = (`date +%s` + 3600) % 86400; scale=3; x / 86.4" | bc'

# radio
alias anonradio='mplayer -quiet http://anonradio.net:8000/anonradio'
alias tilderadio='mplayer -quiet https://radio.tildeverse.org/radio/8000/radio.ogg'
alias sleepbot='mplayer -quiet -playlist "http://www.sleepbot.com/ambience/cgi/listen.cgi/listen.pls"'
alias wrti="mplayer -quiet http://playerservices.streamtheworld.com/api/livestream-redirect/WRTI_CLASSICAL.mp3"

# youtube-dl to get music
alias getmusic="youtube-dl -x --audio-quality 0 --audio-format mp3"

# use color in prompt if not dash. Color works there, but screws up line wrapping
USER=$(id -un)
HOSTNAME=$(uname -n)
# true shell (TS) name
TS=$(ps -cp "$$" -o command="" 2>/dev/null)
if [ -z "$TS" ] || [ "$TS" = "dash" ] || [ "$TS" = "sh" ]; then
  # dash/sh can't render colors properly in the prompt without breaking readline
  PS1="[${HOSTNAME}] " # [hostname]
  PS1=${PS1}'$(basename $(pwd)) ' # workingdir
  PS1=${PS1}"-> " # ->
else
  DIRECTORY_COLOR="\001$(tput setaf 19 0 0)\002";
  PIPE_COLOR="\001$(tput setaf 241 0 0)\002";
  PROMPT_COLOR="\001$(tput setaf 196 0 0)\002";
  HOST_COLOR="\001$(tput setaf 232 0 0)\002"
  RESET_COLOR="\001$(tput sgr0)\002"
  PS1="${HOST_COLOR}${HOSTNAME}" # [hostname]
  PS1=${PS1}"${PIPE_COLOR}|" # [hostname]
  PS1=${PS1}"${DIRECTORY_COLOR}\w" # workingdir
  PS1=${PS1}"\n$PROMPT_COLOR->$RESET_COLOR " # ->
  unset DIRECTORY_COLOR PROMPT_COLOR HOST_COLO RESET_COLOR
fi
export PS1

# Force run bashrc, even if this isn't bash
if [ -f "$HOME/.bashrc" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.bashrc"
fi
# Load local system overrides
if [ -f "$HOME/.profile_local" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.profile_local"
fi

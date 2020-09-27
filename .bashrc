# path
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
path "${HOME}/.config/yarn/global/node_modules/.bin"
path "${HOME}/.node/bin"
path "${HOME}/.local/bin"
path "${HOME}/.fzf/bin"
path "${HOME}/.npm-packages/bin"

# javascript
if command -v node > /dev/null 2>&1; then
  NPM_PACKAGES="${HOME}/.npm-packages"
  export NODE_PATH="/usr/local/lib/jsctags:/usr/local/lib/node:${HOME}/.yarn/bin:/usr/bin/npm"
  export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
  [ -d "$HOME/.yarn" ] && PATH=${PATH}:${HOME}/.yarn/bin
  [ -d "$HOME/.config/yarn" ] && PATH=${PATH}:${HOME}/.config/yarn/global/node_modules/.bin
  [ -d "$HOME/.node" ] && PATH=${PATH}:${HOME}/.node/bin
fi

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
  export ANDROID_HOME="$HOME/sdk"
  PATH=${PATH}:${HOME}/sdk/tools
  PATH=${PATH}:${HOME}/sdk/tools/bin
  PATH=${PATH}:${HOME}/sdk/platform-tools
  PATH=${PATH}:${HOME}/sdk/build-tools/25.0.3
fi


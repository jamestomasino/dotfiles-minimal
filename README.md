# dotfiles

My previous [dotfiles](https://github.com/jamestomasino/dotfiles) collection has grown over the years to encompass a huge variety of features that were `bash` focused. Setup relied on some gnu packages that are not available on all systems. The functions wrapping git functionality and other per-prompt processing loaded down the shell and lengthened startup times.

This repository is a reboot. I've stripped out a lot, but kept most of the more useful features that I take advantage of day-by-day. These dotfiles are designed to run with `/bin/sh` or `dash` as the interactive shell. While I may still run `bash` on some machines for tab-completion, this set should prove more portable.

## Usage

* Install with `install.sh`.
* Uninstall with `uninstall.sh`.

## Linking strategy

The install process will run through this repository up to 3 levels deep looking for individual files. It will link any files into the home directory on an individual file-by-file basis. If the corresponding folder doesn't exist yet, it will be created. The purpose of going file-by-file is to avoid linking any directories and accidentally scooping up other files that may be added there over time.

Over time it is a goal of this repository to move as many of these dotfiles as possible out of the top-level to avoid polluting the home folder.

## Top-level dotfiles

Some configuration files are still stored at the top level and do not respect `XDG_CONFIG_HOME` or even a hard-coded `~/.config`. Several of these have active issues to correct that.

- [.agignore](https://github.com/ggreer/the_silver_searcher/issues/1020)
- [.ctags](https://github.com/universal-ctags/ctags/issues/89)
- [.scimrc](https://github.com/andmarti1424/sc-im/issues/358)
- [.calc_history](https://github.com/lcn2/calc/issues/9)
- ~~.vimrc~~ - fixed with a combo of env vars and config changes
- ~~.curlrc~~ - no public issue logged. **Using CURL_HOME env to fix it**
- [~~.tmux.conf~~](https://github.com/tmux/tmux/issues/142) - obstinately refuse to add the 3 lines of code necessary to support XDG. **Fixing with an alias**

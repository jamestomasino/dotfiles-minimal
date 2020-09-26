# dotfiles

My previous [dotfiles](https://github.com/jamestomasino/dotfiles) collection has grown over the years to encompass a huge variety of features that were `bash` focused. Setup relied on some gnu packages that are not available on all systems. The functions wrapping git functionality and other per-prompt processing loaded down the shell and lengthened startup times.

This repository is a reboot. I've stripped out a lot, but kept most of the more useful features that I take advantage of day-by-day. These dotfiles are designed to run with `/bin/sh` or `dash` as the interactive shell. While I may still run `bash` on some machines for tab-completion, this set should prove more portable.

Installation requires only Make, and will work on BSD or GNU systems.

## Usage

Use `make` to see a list of options:

```sh
$ make

Make targets:
        install   - adds dotfiles to system and inits vim plug
        uninstall - removes dotfiles from system
```

## Linking strategy

`.config/` - This folder often holds a number of dotfiles of a private nature. Rather than store them all in git I choose to keep only the few that are universally applicable. Any dotfiles in this folder are linked individually into `$HOME/.config/` so as to avoid overwriting private ones.

`.functions/` - This folder contains scripts that are all sourced upon shell start. Each file contains a shell function that will be available. They are named the same as the functions they hold.

`bin/` - Some scripts need not be shell functions (and add overhead to the shell). These scripts are linked individually into `$HOME/bin/` to avoid overwriting private ones. This folder is included in the `PATH` environment variable.

All other files or folders are linked directly to `$HOME`.

## Top-level dotfiles

Some configuration files are still stored at the top level and do not respect `XDG_CONFIG_HOME` or even a hard-coded `~/.config`. Several of these have active issues to correct that.

- [.agignore](https://github.com/ggreer/the_silver_searcher/issues/1020)
- [.ctags](https://github.com/universal-ctags/ctags/issues/89)
- [.scimrc](https://github.com/andmarti1424/sc-im/issues/358)
- [.calc_history](https://github.com/lcn2/calc/issues/9)
- ~~.vimrc~~ - unsupported. **using VIMINT and VIMDOTDIR envs it fix it**
- ~~.curlrc~~ - no public issue logged. **Using CURL_HOME env to fix it**
- [~~.tmux.conf~~](https://github.com/tmux/tmux/issues/142) - obstinately refuse to add the 3 lines of code necessary to support XDG. **Fixing with an alias**

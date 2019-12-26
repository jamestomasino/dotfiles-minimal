# dotfiles

My previous [dotfiles](https://github.com/jamestomasino/dotfiles) collection has grown over the years to encompass a huge variety of features that were `bash` focused. Setup relied on some gnu packages that are not available on all systems. The functions wrapping git functionality and other per-prompt processing loaded down the shell and lengthened startup times.

This repository is a reboot. I've stripped out a lot, but kept most of the more useful features that I take advantage of day-by-day. These dotfiles are designed to run with `/bin/sh` or `dash` as the interactive shell. While I may still run `bash` on some machines for tab-completion, this set should prove more portable.

Installation requires only Make, and will work on BSD or GNU systems. Some of the advanced functions, like `z` for directory hopping, may not work on NetBSD or some other obscure flavors, but the majority of the features will persist.

## Usage

Use `make` to see a list of options:

```sh
$ make

Make targets:
        install   - adds dotfiles to system and inits vim plug
        uninstall - removes dotfiles from system
```

## TODO

Some configuration files are still stored at the top level and do not respect `XDG_CONFIG_HOME` or even a hard-coded `~/.config`. Several of these have active issues to correct that.

- [.agignore](https://github.com/ggreer/the_silver_searcher/issues/1020)
- [.ctags](https://github.com/universal-ctags/ctags/issues/89)
- .curlrc - no public issue logged. Perhaps it's in a mailing list?
- [.scimrc](https://github.com/andmarti1424/sc-im/issues/358<Paste>)
- [.tmux.conf](https://github.com/tmux/tmux/issues/142) - obstinately refuse to add the 3 lines of code necessary to support XDG. **Fixing with an alias**
- [.vimrc](https://github.com/vim/vim/issues/2655) - refuses to support. Suggests using neovim (which we do)

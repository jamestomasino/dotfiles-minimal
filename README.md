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

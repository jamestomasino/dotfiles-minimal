D=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

help:
	@printf "Make targets:\\n"
	@printf "\tinstall   - adds dotfiles to system and inits vim\\n"
	@printf "\tuninstall - removes dotfiles from system\\n"

install:
	shopt -s dotglob; for x in *; do if [ "$$x" != ".git" ]; then ln -s "${D}$$x" "$$HOME/$$x"; fi; done
	curl -sfLo "$$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	curl -sfLo "$$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@printf "Launch nvim and vim, then run :PlugInstall\n"

uninstall:
	shopt -s dotglob; for x in *; do rm "$$HOME/$$x"; done

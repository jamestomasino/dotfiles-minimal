help:
	@echo "Make targets:"
	@echo "\tinstall   - adds dotfiles to system and inits vim"
	@echo "\tuninstall - removes dotfiles from system"

install:
	stow -t "$$HOME" .
	curl -sfLo "$$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	curl -sfLo "$$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@printf "Launch nvim and vim, then run :PlugInstall\n"

uninstall:
	stow -D "$$HOME" .

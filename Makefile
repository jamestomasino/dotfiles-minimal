help:
	@printf "Make targets:\\n"
	@printf "\tinstall   - adds dotfiles to system and inits vim\\n"
	@printf "\tuninstall - removes dotfiles from system\\n"

install:
	@for x in * .*; do \
		if [ "$$x" != ".git" ] && [ "$$x" != "." ] && [ "$$x" != ".." ]; then \
			if [ "$$x" = ".config" ]; then \
				cd .config; \
				mkdir -p "$$HOME/.config"; \
				for y in *; do \
					if [ -e "$$HOME/.config/$$y" ]; then \
						printf "File Exists, Skipping: %s\\n" "$$HOME/.config/$$y"; \
					else \
						ln -s "${CURDIR}${.CURDIR}/.config/$$y" "$$HOME/.config/$$y"; \
						printf "Linking: %s%s/.config/%s\\n" "${CURDIR}" "${.CURDIR}" "$$y"; \
					fi; \
				done; \
				cd ..; \
			else \
				if [ -e "$$HOME/$$x" ]; then \
					printf "File Exists, Skipping: %s\\n" "$$HOME/$$x"; \
				else \
					ln -s "${CURDIR}${.CURDIR}/$$x" "$$HOME/$$x"; \
					printf "Linking: %s%s/%s\\n" "${CURDIR}" "${.CURDIR}" "$$x"; \
				fi; \
			fi; \
		fi; \
	done
	@if [ ! -e "$$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then \
		curl -sfLo "$$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; \
	fi
	@if [ ! -e "$$HOME/.vim/autoload/plug.vim" ]; then \
		curl -sfLo "$$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; \
	fi

uninstall:
	@for x in * .*; do \
		if [ "$$x" != ".git" ] && [ "$$x" != "." ] && [ "$$x" != ".." ]; then \
			if [ "$$x" = ".config" ]; then \
				cd .config; \
				for y in *; do \
					rm "$$HOME/.config/$$y"; \
					printf "Removing: %s\\n" "$$HOME/.config/$$y"; \
				done; \
			else \
				rm "$$HOME/$$x"; \
				printf "Removing: %s\\n" "$$HOME/$$x"; \
			fi; \
		fi; \
	done

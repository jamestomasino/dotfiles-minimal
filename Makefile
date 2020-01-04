help:
	@printf "Make targets:\\n"
	@printf "\tinstall   - adds dotfiles to system and inits vim plug\\n"
	@printf "\tuninstall - removes dotfiles from system\\n"

install:
	@for x in * .*; do \
		if [ "$$x" != ".git" ] && [ "$$x" != "." ] && [ "$$x" != ".." ] && [ "$$x" != "Makefile" ]; then \
			if [ "$$x" = ".config" ]; then \
				cd .config; \
				mkdir -p "$$HOME/.config"; \
				for y in *; do \
					if [ -e "$$HOME/.config/$$y" ]; then \
						printf "File Exists, Skipping: %s\\n" "$$HOME/.config/$$y"; \
					else \
						ln -sfn "${CURDIR}${.CURDIR}/.config/$$y" "$$HOME/.config/$$y"; \
						printf "Linking: %s%s/.config/%s\\n" "${CURDIR}" "${.CURDIR}" "$$y"; \
					fi; \
				done; \
				cd ..; \
			elif [ "$$x" = "bin" ]; then \
				cd bin; \
				mkdir -p "$$HOME/bin"; \
				for y in *; do \
					if [ -e "$$HOME/bin/$$y" ]; then \
						printf "File Exists, Skipping: %s\\n" "$$HOME/bin/$$y"; \
					else \
						ln -sfn "${CURDIR}${.CURDIR}/bin/$$y" "$$HOME/bin/$$y"; \
						printf "Linking: %s%s/bin/%s\\n" "${CURDIR}" "${.CURDIR}" "$$y"; \
					fi; \
				done; \
				cd ..; \
			else \
				if [ -e "$$HOME/$$x" ]; then \
					printf "File Exists, Skipping: %s\\n" "$$HOME/$$x"; \
				else \
					ln -sfn "${CURDIR}${.CURDIR}/$$x" "$$HOME/$$x"; \
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
		if [ "$$x" != ".git" ] && [ "$$x" != "." ] && [ "$$x" != ".." ] && [ "$$x" != "Makefile" ]; then \
			if [ "$$x" = ".config" ]; then \
				cd .config; \
				for y in *; do \
					rm "$$HOME/.config/$$y"; \
					printf "Removing: %s\\n" "$$HOME/.config/$$y"; \
				done; \
				cd ..; \
			elif [ "$$x" = "bin" ]; then \
				cd bin; \
				for y in *; do \
					rm "$$HOME/bin/$$y"; \
					printf "Removing: %s\\n" "$$HOME/bin/$$y"; \
				done; \
				cd ..; \
			else \
				rm "$$HOME/$$x"; \
				printf "Removing: %s\\n" "$$HOME/$$x"; \
			fi; \
		fi; \
	done

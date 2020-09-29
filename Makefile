SHELL=/usr/bin/env bash -O extglob -c

help:
	@printf "Make targets:\\n"
	@printf "\tinstall   - adds dotfiles to system and inits vim plug\\n"
	@printf "\tuninstall - removes dotfiles from system\\n"

install:
	@shopt -s dotglob; \
	for x in *; do \
		if [ "$$x" != ".git" ] && [ "$$x" != "." ] && [ "$$x" != ".." ] && [ "$$x" != "Makefile" ] && [ "$$x" != "README.md" ]; then \
			if [ -d "$$x" ]; then \
				cd "$$x"; \
				mkdir -p "$$HOME/$$x"; \
				for y in *; do \
					if [ -d "${CURDIR}${.CURDIR}/$$x/$$y" ]; then \
						cd "$$y"; \
						mkdir -p "$$HOME/$$x/$$y"; \
						for z in *; do \
							if [ -e "$$HOME/$$x/$$y/$$z" ]; then \
								printf "File Exists, Skipping: %s\\n" "$$HOME/$$x/$$y/$$z"; \
							else \
								ln -sfn "${CURDIR}${.CURDIR}/$$x/$$y/$$z" "$$HOME/$$x/$$y/$$z"; \
								printf "Linking: %s/%s/%s/%s\\n" "${CURDIR}${.CURDIR}" "$$x" "$$y" "$$z"; \
							fi; \
						done; \
						cd ..; \
					else \
						if [ -e "$$HOME/$$x/$$y" ]; then \
							printf "File Exists, Skipping: %s\\n" "$$HOME/$$x/$$y"; \
						else \
							ln -sfn "${CURDIR}${.CURDIR}/$$x/$$y" "$$HOME/$$x/$$y"; \
							printf "Linking: %s%s/%s/%s\\n" "${CURDIR}" "${.CURDIR}" "$$x" "$$y"; \
						fi; \
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
	@if [ ! -e "$$HOME/.local/share/vim/autoload/plug.vim" ]; then \
		curl -sfLo "$$HOME/.local/share/vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; \
	fi

uninstall:
	@shopt -s dotglob; \
	for x in *; do \
		if [ "$$x" != ".git" ] && [ "$$x" != "." ] && [ "$$x" != ".." ] && [ "$$x" != "Makefile" ] && [ "$$x" != "README.md" ]; then \
			if [ -d "$$x" ]; then \
				cd "$$x"; \
				for y in *; do \
					if [ -d "${CURDIR}${.CURDIR}/$$x/$$y" ]; then \
						cd "$$y"; \
						for z in *; do \
							if [ -L "$$HOME/$$x/$$y/$$z" ]; then \
								unlink "$$HOME/$$x/$$y/$$z"; \
								printf "Removing: %s\\n" "$$HOME/$$x/$$y/$$z"; \
							fi; \
						done; \
						cd ..; \
					else \
						if [ -L "$$HOME/$$x/$$y" ]; then \
							unlink "$$HOME/$$x/$$y"; \
							printf "Removing: %s\\n" "$$HOME/$$x/$$y"; \
						fi; \
					fi; \
				done; \
				cd ..; \
			else \
				if [ -L "$$HOME/$$x" ]; then \
					unlink "$$HOME/$$x"; \
					printf "Removing: %s\\n" "$$HOME/$$x"; \
				fi; \
			fi; \
		fi; \
	done

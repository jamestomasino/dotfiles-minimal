SHELL=/usr/bin/env bash -O extglob -c
CONFIG="config"
XDG_DEST=".config"
BIN="bin"
BIN_DEST="bin"

help:
	@printf "Make targets:\\n"
	@printf "\tinstall   - adds dotfiles to system and inits vim plug\\n"
	@printf "\tuninstall - removes dotfiles from system\\n"

install:
	@shopt -s dotglob; \
	for x in *; do \
		if [ "$$x" != ".git" ] && [ "$$x" != "." ] && [ "$$x" != ".." ] && [ "$$x" != "Makefile" ] && [ "$$x" != "README.md" ]; then \
			if [ "$$x" = "$(CONFIG)" ]; then \
				cd $(CONFIG); \
				mkdir -p "$$HOME/$(CONFIG)"; \
				for y in *; do \
					if [ -f "${CURDIR}${.CURDIR}/$(CONFIG)/$$y" ]; then \
						ln -sfn "${CURDIR}${.CURDIR}/$(CONFIG)/$$y" "$$HOME/$(XDG_DEST)/$$y"; \
					else \
						if [ ! -e "$$HOME/$(XDG_DEST)/$$y" ]; then \
							mkdir -p "$$HOME/$(XDG_DEST)/$$y"; \
						fi; \
						cd "$$y"; \
						for z in *; do \
						if [ -e "$$HOME/$(XDG_DEST)/$$y/$$z" ]; then \
								printf "File Link Exists, Skipping: %s\\n" "$$HOME/$(XDG_DEST)/$$y/$$z"; \
							else \
								ln -sfn "${CURDIR}${.CURDIR}/$(CONFIG)/$$y/$$z" "$$HOME/$(XDG_DEST)/$$y/$$z"; \
								printf "Linking: %s%s/$(CONFIG)/%s/%s\\n" "${CURDIR}" "${.CURDIR}" "$$y" "$$z"; \
							fi; \
						done; \
						cd - > /dev/null; \
					fi; \
				done; \
				cd ..; \
			elif [ "$$x" = "$(BIN)" ]; then \
				cd $(BIN_DEST); \
				mkdir -p "$$HOME/$(BIN_DEST)"; \
				for y in *; do \
					if [ -e "$$HOME/$(BIN_DEST)/$$y" ]; then \
						printf "File Exists, Skipping: %s\\n" "$$HOME/$(BIN_DEST)/$$y"; \
					else \
						ln -sfn "${CURDIR}${.CURDIR}/$($(BIN_DEST))/$$y" "$$HOME/$(BIN_DEST)/$$y"; \
						printf "Linking: %s%s/$(BIN)/%s\\n" "${CURDIR}" "${.CURDIR}" "$$y"; \
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
	for x in * .*; do \
		if [ "$$x" != ".git" ] && [ "$$x" != "." ] && [ "$$x" != ".." ] && [ "$$x" != "Makefile" ] && [ "$$x" != "README.md" ]; then \
			if [ "$$x" = "$(CONFIG)" ]; then \
				cd $(CONFIG); \
				for y in *; do \
					if [ -L "$$HOME/$(XDG_DEST)/$$y" ]; then \
						unlink "$$HOME/$(XDG_DEST)/$$y"; \
					elif [ -d "$$HOME/$(XDG_DEST)/$$y" ]; then \
						cd "$$y"; \
						for z in *; do \
							if [ -L "$$HOME/$(XDG_DEST)/$$y/$$z" ]; then \
								unlink "$$HOME/$(XDG_DEST)/$$y/$$z"; \
								printf "Removing: %s\\n" "$$HOME/$(XDG_DEST)/$$y/$$z"; \
							fi; \
						done; \
						cd - > /dev/null; \
					fi; \
				done; \
				cd ..; \
			elif [ "$$x" = "$(BIN)" ]; then \
				cd $(BIN_DEST); \
				for y in *; do \
					if [ -L "$$HOME/$(BIN_DEST)/$$y" ]; then \
						unlink "$$HOME/$(BIN_DEST)/$$y"; \
						printf "Removing: %s\\n" "$$HOME/$(BIN_DEST)/$$y"; \
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

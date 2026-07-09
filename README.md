# dotfiles-minimal

Minimal, portable dotfiles for a `/bin/sh` or `dash` interactive shell. Designed
to work across machines with minimal dependencies, though some tools (like
`bash`) may still be used where they add value.

## What's included

| Category | Tools |
|----------|-------|
| Shell | `.profile`, `.bashrc`, `.inputrc`, shell functions (`.functions/`) |
| Terminal | `tmux`, `kitty` (desktop-only) |
| Editor | `vim` (vim-plug, fzf, pencil, goyo) |
| Email | `aerc` (Dracula theme) |
| Media | `cmus`, `mpv`, `mplayer` |
| News & RSS | `newsboat` |
| Web | `curl`, `lynx` |
| Dev | `git` (delta pager, fugitive merge tool, GPG signing) |
| Utilities | `sc-im`, `remind`, `phetch`, `slrn`, `ag`, `vf1`, `imwheel` (desktop-only) |
| Scripts | 25 custom binaries in `bin/` (audiobooks, music, news, clipboard, file management) |
| AI | `jcode` LSP/agent configuration with skills library |

## Requirements

- **POSIX sh** — `dash`, `ash`, or any POSIX-compliant shell for install/uninstall scripts
- **coreutils** — `ln`, `mkdir`, `pwd`, `find`, `rm`
- **symlinks** — your home directory filesystem must support them

Optional tools depend on what you have installed on a given machine. The install
script skips files for tools that aren't present without failing.

## Usage

```bash
# Clone the repository
git clone https://github.com/jamestomasino/dotfiles-minimal.git
cd dotfiles-minimal

# Install (link files into your home directory)
./install.sh

# Install with desktop-only configs (kitty, imwheel)
./install.sh --desktop

# Uninstall (remove symlinks and empty directories)
./uninstall.sh
```

## Linking strategy

The install process walks the repository with `find`, creating symlinks for
each **individual file** into the corresponding location in your home directory.
Directories themselves are never symlinked. This prevents accidentally pulling in
untracked files that may be created inside a config directory over time.

Files that are skipped during install:
- `.git/` (version control)
- `.gitignore`
- `install.sh`, `uninstall.sh` (management scripts)
- `README.md`

Desktop-only entries (`kitty`, `imwheel`) are skipped unless `--desktop` is
passed.

## Directory structure

```
├── .profile          # Shell profile (aliases, PATH, environment)
├── .bashrc           # Bash-specific settings
├── .inputrc          # Readline configuration
├── .imwheelrc        # Mouse wheel mapping (desktop)
├── .functions/       # Shell functions (cd, fd, fda, z, etc.)
├── .config/          # XDG config files (vim, tmux, git, mpv, etc.)
├── bin/              # Custom utility scripts
├── install.sh        # Install script
├── uninstall.sh      # Uninstall script
└── README.md
```

## Notes

- Run `./install.sh` after pulling updates to pick up new or changed files.
- Existing files in your home directory are **not overwritten**. The installer
  skips them and prints a warning.
- The `--desktop` flag is intended for local machines. On servers or minimal
  systems, omit it to skip GUI-dependent configs.

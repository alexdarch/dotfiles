# ~/.profile — shared environment for bash and zsh
# Sourced by .bashrc and .zshrc so env is consistent across shells

# ============================================================
# PATH
# ============================================================
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# ============================================================
# Defaults
# ============================================================
export EDITOR="code --wait"
export VISUAL="$EDITOR"
export LANG="en_US.UTF-8"
export LC_ALL=""

# ============================================================
# Tool init (cross-shell)
# ============================================================

# zoxide (smarter cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init "$(basename "$SHELL")")"

# ============================================================
# Aliases (shared)
# ============================================================
alias ls='ls --color=auto -hv'
alias ll='ls -l'
alias la='ls -lA'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias mv='mv -i'
alias cp='cp -i'

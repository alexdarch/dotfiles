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
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=always --group-directories-first'
    alias ll='eza -lh --git --color=always --group-directories-first'
    alias la='eza -lah --git --color=always --group-directories-first'
    alias lt='eza -lh --tree --level=2 --color=always'
else
    alias ls='ls --color=auto -hv'
    alias ll='ls --color=auto -lh'
    alias la='ls --color=auto -lAh'
fi


if command -v rg >/dev/null 2>&1; then
    alias grep='rg'
else
    alias grep='grep --color=auto'
fi
alias diff='diff --color=auto'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'

# ~/.bashrc — bash-specific interactive config

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ============================================================
# Shared environment
# ============================================================
[ -f ~/.profile ] && . ~/.profile

# ============================================================
# History
# ============================================================
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=100000
HISTFILESIZE=100000
shopt -s histappend

# ============================================================
# Shell options
# ============================================================
shopt -s checkwinsize   # Update LINES/COLUMNS after each command
shopt -s globstar       # ** matches recursively
shopt -s cdspell        # Autocorrect minor cd typos
shopt -s dirspell       # Autocorrect minor dir typos in completion

# ============================================================
# Completion
# ============================================================
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ============================================================
# Prompt
# ============================================================
PROMPT_FILE="${HOME}/source/dotfiles/shell/prompt.bash"
[ -f "$PROMPT_FILE" ] && . "$PROMPT_FILE"

# ============================================================
# Colors
# ============================================================
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# ============================================================
# fzf
# ============================================================
if command -v fzf >/dev/null 2>&1; then
    [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash
    [ -f /usr/share/doc/fzf/examples/completion.bash ] && . /usr/share/doc/fzf/examples/completion.bash
fi
export PATH="$HOME/.local/bin:$PATH"
. "$HOME/.cargo/env"

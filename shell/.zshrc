# ~/.zshrc — zsh-specific interactive config

# ============================================================
# Shared environment
# ============================================================
[ -f ~/.profile ] && . ~/.profile

# ============================================================
# Zinit Plugin Manager (auto-install)
# ============================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME/.git" ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# ============================================================
# Plugins (turbo mode — load after prompt for fast startup)
# ============================================================
zinit wait lucid light-mode for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions

# ============================================================
# History
# ============================================================
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# ============================================================
# Directory navigation
# ============================================================
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ============================================================
# Key bindings (emacs-style)
# ============================================================
bindkey -e
bindkey "^[[A" history-beginning-search-backward    # Up arrow
bindkey "^[[B" history-beginning-search-forward     # Down arrow
bindkey "^[[1;5C" forward-word                      # Ctrl+Right
bindkey "^[[1;5D" backward-word                     # Ctrl+Left
bindkey "^[[3~" delete-char                         # Delete
bindkey "^[[H" beginning-of-line                    # Home
bindkey "^[[F" end-of-line                          # End

# ============================================================
# Completion
# ============================================================
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ============================================================
# fzf
# ============================================================
if command -v fzf >/dev/null 2>&1; then
    [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
fi

# ============================================================
# Prompt
# ============================================================
PROMPT_FILE="${HOME}/source/dotfiles/shell/prompt.zsh"
[ -f "$PROMPT_FILE" ] && . "$PROMPT_FILE"

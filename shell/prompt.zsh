# Zsh prompt: user@host: path [git] %
# Sources git's built-in __git_ps1 for branch/status display

# ============================================================
# Git prompt (__git_ps1)
# ============================================================
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    . /usr/lib/git-core/git-sh-prompt
elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    . /usr/share/git-core/contrib/completion/git-prompt.sh
fi

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto verbose"

# ============================================================
# Prompt (requires PROMPT_SUBST for $(__git_ps1) expansion)
# ============================================================
setopt PROMPT_SUBST

PROMPT='%F{green}%n@%m%f: %F{blue}%~%f%F{yellow}$(__git_ps1 " [%s]")%f $ '

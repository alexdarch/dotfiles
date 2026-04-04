# Bash prompt: user@host: path [git] $
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
# Colors
# ============================================================
C_USER='\[\033[01;32m\]'
C_PATH='\[\033[01;34m\]'
C_GIT='\[\033[33m\]'
C_RST='\[\033[00m\]'

# ============================================================
# Prompt
# ============================================================
PS1="${C_USER}\u@\h${C_RST}: ${C_PATH}\w${C_GIT}\$(__git_ps1 ' [%s]')${C_RST} "

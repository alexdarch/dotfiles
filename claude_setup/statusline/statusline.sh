#!/bin/bash
# Claude Code statusline - reads JSON from stdin
# Line 1: [time magenta] model (blue) | path (dark blue) git (light blue)
# Line 2: context bar (green/orange/red) with tokens | cost (yellow)
# Uses node for JSON parsing (available via Claude Code, no jq dependency)

DATA=$(cat)

# Parse all JSON fields in one node call
eval "$(echo "$DATA" | node -e "
const d=[];
process.stdin.on('data',c=>d.push(c));
process.stdin.on('end',()=>{
  try {
    const j=JSON.parse(d.join(''));
    const out = (k,v) => console.log(k+'='+JSON.stringify(v||''));
    out('J_CWD', j.cwd);
    out('J_MODEL', (j.model||{}).display_name);
    out('J_PCT', (j.context_window||{}).used_percentage);
    out('J_WIN', (j.context_window||{}).context_window_size);
    out('J_COST', (j.cost||{}).total_cost_usd);
  } catch(e) {}
});
")"

# ANSI escape codes
RST=$'\e[0m'
DARK_BLUE=$'\e[38;5;33m'
LIGHT_BLUE=$'\e[38;5;117m'
MODEL_BLUE=$'\e[38;5;75m'
MAGENTA=$'\e[38;5;170m'
GREEN=$'\e[38;5;78m'
YELLOW=$'\e[38;5;214m'
RED=$'\e[38;5;196m'
DIM=$'\e[2m'

# --- Line 1: [time model] path git ---
DIR=$(basename "$J_CWD" 2>/dev/null || echo "?")

GIT_INFO=""
if [ -n "$J_CWD" ] && git -C "$J_CWD" rev-parse --git-dir &>/dev/null; then
    BRANCH=$(git --no-optional-locks -C "$J_CWD" branch --show-current 2>/dev/null)
    DIRTY=""
    git --no-optional-locks -C "$J_CWD" diff --quiet 2>/dev/null || DIRTY="*"
    git --no-optional-locks -C "$J_CWD" diff --cached --quiet 2>/dev/null || DIRTY="${DIRTY}+"
    if [ -n "$BRANCH" ]; then
        GIT_INFO=" ${LIGHT_BLUE}${BRANCH}${DIRTY}${RST}"
    fi
fi

MODEL_PART=""
if [ -n "$J_MODEL" ]; then
    MODEL_PART=" ${MODEL_BLUE}${J_MODEL}${RST}"
fi

TIME=$(date +"%H:%M")

echo "${DIM}[${RST}${MAGENTA}${TIME}${RST}${MODEL_PART}${DIM}]${RST} ${DARK_BLUE}${DIR}${RST}${GIT_INFO}"

# --- Line 2: context bar with tokens | cost ---
BAR_WIDTH=20

if [ -n "$J_PCT" ]; then
    PCT=$(printf "%.0f" "$J_PCT")

    # Color based on usage
    if [ "$PCT" -lt 30 ]; then
        BAR_COLOR="$GREEN"
    elif [ "$PCT" -lt 70 ]; then
        BAR_COLOR="$YELLOW"
    else
        BAR_COLOR="$RED"
    fi

    FILLED=$(( BAR_WIDTH * PCT / 100 ))
    EMPTY=$(( BAR_WIDTH - FILLED ))
    FILLED_BAR=$(printf '%0.s█' $(seq 1 "$FILLED") 2>/dev/null)
    EMPTY_BAR=$(printf '%0.s░' $(seq 1 "$EMPTY") 2>/dev/null)
    BAR="${BAR_COLOR}${FILLED_BAR}${DIM}${EMPTY_BAR}${RST}"

    # Derive current token usage from percentage and window size
    if [ -n "$J_WIN" ]; then
        WIN=$(printf "%.0f" "$J_WIN")
        USED_TOKENS=$(( WIN * PCT / 100 / 1000 ))
        MAX_TOKENS=$(( WIN / 1000 ))
        TOKENS="${DIM}${USED_TOKENS}k / ${MAX_TOKENS}k${RST}"
    else
        TOKENS="${DIM}? / ?${RST}"
    fi

    CTX_LINE="${BAR_COLOR}ctx:${RST} ${BAR} ${BAR_COLOR}${PCT}%${RST} ${TOKENS}"
else
    EMPTY_BAR=$(printf '%0.s░' $(seq 1 "$BAR_WIDTH"))
    CTX_LINE="${DIM}ctx: ${EMPTY_BAR} -%${RST}"
fi

if [ -n "$J_COST" ]; then
    COST_FMT=$(printf "%.2f" "$J_COST")
    CTX_LINE="${CTX_LINE} ${DIM}|${RST} ${YELLOW}\$${COST_FMT}${RST}"
fi

echo "$CTX_LINE"

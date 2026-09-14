# ~/.zshrc — Interactive zsh Setup
# Agnoster-style Prompt, Oh-My-zsh Features Implemented Directly against zsh
# Plugin Packages (No Framework). Sources Plugin Files from the Artix Package
# Locations.

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
export EDITOR=vim
export VISUAL="$EDITOR"
export PAGER=less
export LESS="-R"
export LANG="${LANG:-en_US.UTF-8}"

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS       # Skip Duplicates in History Writes
setopt HIST_IGNORE_ALL_DUPS   # Drop Older Duplicates when a New One Lands
setopt HIST_IGNORE_SPACE      # Commands Starting with a Space Are Not Recorded
setopt HIST_REDUCE_BLANKS     # Trim Redundant Whitespace
setopt SHARE_HISTORY          # Share History between Running Shells
setopt EXTENDED_HISTORY       # Record Timestamps and Durations

# ---------------------------------------------------------------------------
# Directory Navigation and Options
# ---------------------------------------------------------------------------
setopt AUTO_CD                # Typing a Directory Path Cds into It
setopt AUTO_PUSHD             # Push Directories onto the Stack Automatically
setopt PUSHD_IGNORE_DUPS
setopt CORRECT                # Suggest Corrections for Command Spellings
setopt INTERACTIVE_COMMENTS   # Allow Comments on the Interactive Line
setopt NO_BEEP

# Completion Cache
zstyle ':completion:*' cache-path ~/.zsh/cache
mkdir -p ~/.zsh/cache

# ---------------------------------------------------------------------------
# Plugins (Artix Packages)
# ---------------------------------------------------------------------------
fpath+=(/usr/share/zsh/site-functions /usr/share/zsh/vendor-completions)

autoload -Uz compinit
# Daily Compinit Cache; Guard with -C when the Dump Is Fresh
if [[ -n ${ZSH_VERSION} ]]; then
  if [[ "$(find ~/.zsh/cache -name 'zcompdump' -mtime -1 -print -quit 2>/dev/null)" ]]; then
    compinit -C -d ~/.zsh/cache/zcompdump
  else
    compinit -d ~/.zsh/cache/zcompdump
  fi
fi

# Fish-Like Autosuggestions as You Type
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Syntax Highlighting for the Command Line (Keep Last among Line Plugins)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History Substring Search: Type Part of a Command, Arrow Up
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# git Completion Ships with git; zsh-completions Adds the Rest
[[ -f /usr/share/zsh/site-functions/_git ]] && fpath+=(/usr/share/zsh/site-functions)
fpath+=(/usr/share/zsh/functions/Completion)

# ---------------------------------------------------------------------------
# Key Bindings
# ---------------------------------------------------------------------------
bindkey -e                          # Emacs Mode
bindkey '^[[1;5C' forward-word      # Ctrl+right
bindkey '^[[1;5D' backward-word     # Ctrl+left
bindkey '^[.'  insert-last-word     # Alt+. Inserts Last Argument
bindkey '^[q' push-line             # Alt+q

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -la'
alias l='ls -lah'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ip='ip -color=auto'
alias mkdir='mkdir -pv'
alias sudo='sudo '   # Trailing Space: Expand Aliases after sudo
alias history='fc -il 1'

# System Management on dinit
alias sc='sudo dinitctl'
alias sv='dinitctl status'

# ---------------------------------------------------------------------------
# Prompt — Agnoster, Implemented Directly
# ---------------------------------------------------------------------------
# Start Background Jobs with a Clean Prompt Segment State
setopt PROMPT_SUBST

PROMPT_SEG_SEP=$'\ue0b0'          # Right-Pointing Solid Triangle
PROMPT_SEG_SEP_THIN=$'\ue0b1'     # Right-Pointing Thin Triangle

# 256-Color Fallbacks when Truecolor Is Unavailable
autoload -Uz colors && colors

# Segment Helper: Draw <Bg=fg> Text with the Triangle Separator
prompt_segment() {
  local bg fg text
  bg=$1; fg=$2; text=$3
  local bg_code=$(color_to_code "$bg") fg_code=$(color_to_code "$fg")
  print -n "%F{$bg_code}%K{$bg_code} $text %F{$fg_code}%k${PROMPT_SEG_SEP} "
}

# Resolve Names and Hex Codes to zsh Color Specs
color_to_code() {
  case "$1" in
    \#*) printf '%s' "$1" ;;               # Hex Passes Through
    *)   printf '%s' "$1" ;;               # Named Color Passes Through
  esac
}

# git Segment: Branch + Dirty/clean Marker
prompt_git() {
  (( $+commands[git] )) || return
  local branch dirty=""
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    dirty="*"
  fi
  prompt_segment yellow black "${branch} ${dirty}"
}

# Previous Command Status Segment: Green when OK, Red with Code when Failed
prompt_status() {
  local code=$?
  if (( code != 0 )); then
    prompt_segment red white "${code}"
  fi
}

# Context Segment: User@host, Only over Ssh or when root
prompt_context() {
  if [[ -n $SSH_CONNECTION || $USER == root ]]; then
    prompt_segment black white "%n@%m"
  fi
}

set_prompt() {
  PROMPT=''
  PROMPT+='$(prompt_status)'
  PROMPT+='$(prompt_context)'
  PROMPT+='$(prompt_git)'
  PROMPT+='$(prompt_segment blue white "%3~")'   # Last Three Path Components
  PROMPT+='%{$reset_color%}'
}
set_prompt

# Re-Evaluate on Every Prompt Draw
precmd() { set_prompt; }

# ---------------------------------------------------------------------------
# Extra Oh-My-zsh-Like Behavior, Implemented Inline
# ---------------------------------------------------------------------------
# Colored Completions with Group Headers and a Menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}=*' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*' squeeze-slashes true

# Case-Insensitive Completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Cd Completion Shows Recent Directories (Cdr Ecosystem, No Plugin Needed)
autoload -Uz zmv

# Command-Not-Found Hint via Pkgfile when Present
if (( $+commands[pkgfile] )); then
  source /usr/share/doc/pkgfile/command-not-found.zsh 2>/dev/null
fi

# Safe Replacement in History Expansion
setopt HIST_VERIFY

# Keep a Running Clock in Titles; Terminal Title Shows Cwd
case $TERM in
  xterm*|alacritty|*) precmd_functions+=(set_title) ;;
esac
set_title() {
  print -Pn "\e]0;%n@%m: %~\a"
}
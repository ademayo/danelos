# ~/.zshrc — interactive zsh setup
# Agnoster-style prompt, oh-my-zsh features implemented directly against zsh
# plugin packages (no framework). Sources plugin files from the Artix package
# locations.

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
setopt HIST_IGNORE_DUPS       # skip duplicates in history writes
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicates when a new one lands
setopt HIST_IGNORE_SPACE      # commands starting with a space are not recorded
setopt HIST_REDUCE_BLANKS     # trim redundant whitespace
setopt SHARE_HISTORY          # share history between running shells
setopt EXTENDED_HISTORY       # record timestamps and durations

# ---------------------------------------------------------------------------
# Directory navigation and options
# ---------------------------------------------------------------------------
setopt AUTO_CD                # typing a directory path cds into it
setopt AUTO_PUSHD             # push directories onto the stack automatically
setopt PUSHD_IGNORE_DUPS
setopt CORRECT                # suggest corrections for command spellings
setopt INTERACTIVE_COMMENTS   # allow comments on the interactive line
setopt NO_BEEP

# completion cache
zstyle ':completion:*' cache-path ~/.zsh/cache
mkdir -p ~/.zsh/cache

# ---------------------------------------------------------------------------
# Plugins (Artix packages)
# ---------------------------------------------------------------------------
fpath+=(/usr/share/zsh/site-functions /usr/share/zsh/vendor-completions)

autoload -Uz compinit
# daily compinit cache; guard with -C when the dump is fresh
if [[ -n ${ZSH_VERSION} ]]; then
  if [[ "$(find ~/.zsh/cache -name 'zcompdump' -mtime -1 -print -quit 2>/dev/null)" ]]; then
    compinit -C -d ~/.zsh/cache/zcompdump
  else
    compinit -d ~/.zsh/cache/zcompdump
  fi
fi

# fish-like autosuggestions as you type
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# syntax highlighting for the command line (keep last among line plugins)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# history substring search: type part of a command, arrow up
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# git completion ships with git; zsh-completions adds the rest
[[ -f /usr/share/zsh/site-functions/_git ]] && fpath+=(/usr/share/zsh/site-functions)
fpath+=(/usr/share/zsh/functions/Completion)

# ---------------------------------------------------------------------------
# Key bindings
# ---------------------------------------------------------------------------
bindkey -e                          # emacs mode
bindkey '^[[1;5C' forward-word      # ctrl+right
bindkey '^[[1;5D' backward-word     # ctrl+left
bindkey '^[.'  insert-last-word     # alt+. inserts last argument
bindkey '^[q' push-line             # alt+q

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
alias sudo='sudo '   # trailing space: expand aliases after sudo
alias history='fc -il 1'

# system management on dinit
alias sc='sudo dinitctl'
alias sv='dinitctl status'

# ---------------------------------------------------------------------------
# Prompt — agnoster, implemented directly
# ---------------------------------------------------------------------------
# start background jobs with a clean prompt segment state
setopt PROMPT_SUBST

PROMPT_SEG_SEP=$'\ue0b0'          # right-pointing solid triangle
PROMPT_SEG_SEP_THIN=$'\ue0b1'     # right-pointing thin triangle

# 256-color fallbacks when truecolor is unavailable
autoload -Uz colors && colors

# segment helper: draw <bg=fg> text with the triangle separator
prompt_segment() {
  local bg fg text
  bg=$1; fg=$2; text=$3
  local bg_code=$(color_to_code "$bg") fg_code=$(color_to_code "$fg")
  print -n "%F{$bg_code}%K{$bg_code} $text %F{$fg_code}%k${PROMPT_SEG_SEP} "
}

# resolve names and hex codes to zsh color specs
color_to_code() {
  case "$1" in
    \#*) printf '%s' "$1" ;;               # hex passes through
    *)   printf '%s' "$1" ;;               # named color passes through
  esac
}

# git segment: branch + dirty/clean marker
prompt_git() {
  (( $+commands[git] )) || return
  local branch dirty=""
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    dirty="*"
  fi
  prompt_segment yellow black "${branch} ${dirty}"
}

# previous command status segment: green when ok, red with code when failed
prompt_status() {
  local code=$?
  if (( code != 0 )); then
    prompt_segment red white "${code}"
  fi
}

# context segment: user@host, only over ssh or when root
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
  PROMPT+='$(prompt_segment blue white "%3~")'   # last three path components
  PROMPT+='%{$reset_color%}'
}
set_prompt

# re-evaluate on every prompt draw
precmd() { set_prompt; }

# ---------------------------------------------------------------------------
# Extra oh-my-zsh-like behavior, implemented inline
# ---------------------------------------------------------------------------
# colored completions with group headers and a menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}=*' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*' squeeze-slashes true

# case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# cd completion shows recent directories (cdr ecosystem, no plugin needed)
autoload -Uz zmv

# command-not-found hint via pkgfile when present
if (( $+commands[pkgfile] )); then
  source /usr/share/doc/pkgfile/command-not-found.zsh 2>/dev/null
fi

# safe replacement in history expansion
setopt HIST_VERIFY

# keep a running clock in titles; terminal title shows cwd
case $TERM in
  xterm*|alacritty|*) precmd_functions+=(set_title) ;;
esac
set_title() {
  print -Pn "\e]0;%n@%m: %~\a"
}
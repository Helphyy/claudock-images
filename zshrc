#!/usr/bin/env zsh
# claudock-base zshrc: oh-my-zsh + plugins + Kali/Exegol-inspired two-line prompt.

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

# Theme is left empty: we set our own PROMPT below, so oh-my-zsh skips its own.
ZSH_THEME=""

plugins=(
  git
  docker
  python
  pip
  npm
  command-not-found
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

umask 002

# History
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# Load oh-my-zsh (plugins, completions)
source "$ZSH/oh-my-zsh.sh"

# === Claudock prompt ==========================================================
# Two-line, container-aware, Kali-inspired:
#
#   ┌─[claudock]─(root@<hostname>)─[~/path]
#   └─#
#
# Colors: cyan brackets, magenta brand, red user, blue host (= container name),
# green path, red prompt char.
autoload -Uz colors && colors

setopt PROMPT_SUBST

_claudock_path() {
  local p="${PWD/#$HOME/~}"
  if (( ${#p} > 40 )); then
    p=".../${p##*/}"
  fi
  printf '%s' "$p"
}

PROMPT='%F{cyan}┌─[%F{magenta}claudock%F{cyan}]─(%F{red}%n%F{cyan}@%F{blue}%m%F{cyan})─[%F{green}$(_claudock_path)%F{cyan}]%f
%F{cyan}└─%F{red}#%f '

RPROMPT='%(?..%F{red}[exit %?]%f )'

# Recording indicator (overrides the left side of PROMPT)
if [[ -n "$ASCIINEMA_REC" ]]; then
  PROMPT="%F{red}[REC]%f $PROMPT"
fi

# === Aliases ==================================================================
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias gd='git diff'
alias gco='git checkout'
alias gl='git log --oneline --decorate --graph -20'
alias rg='rg --smart-case'
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'
if command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
  alias cat='batcat --paging=never --style=plain'
fi
alias cc='claude'
command -v http >/dev/null 2>&1 && alias http='http --style=fruity'

# === Completions / hooks ======================================================
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)" 2>/dev/null
fi

# === MOTD on the first interactive shell of a session ========================
if [[ -z "$CLAUDOCK_GREETED" && -o interactive && -f /etc/claudock-motd ]]; then
  export CLAUDOCK_GREETED=1
  printf '%b' "$(cat /etc/claudock-motd)"
fi

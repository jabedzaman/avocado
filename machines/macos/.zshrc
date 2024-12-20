# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zap-zsh/exa"
plug "zsh-users/zsh-syntax-highlighting"

fpath+=(~/.config/hcloud/completion/zsh)

# Load and initialise completion system
autoload -Uz compinit
compinit

# startship
eval "$(starship init zsh)"

# zoxide
eval "$(zoxide init zsh)"

# aliases
alias cd='z'
alias search="fd . --type f --hidden --exclude .git --ignore-file .gitignore | fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' | xargs nvim"
alias projects="find ~/Developer -mindepth 1 -maxdepth 1 -type d -print | fzf --preview 'ls -1 {}' --bind 'enter:execute(nvim {}),ctrl-c:execute(code {})'"

# pnpm
export PNPM_HOME="/Users/jabed/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# fzf
source <(fzf --zsh)

# fnm
FNM_PATH="/Users/jabed/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/jabed/Library/Application Support/fnm:$PATH"
  eval "`fnm env`"
fi
export PATH="/Users/jabed/.local/state/fnm_multishells/16501_1721154257393/bin":$PATH
export FNM_DIR="/Users/jabed/.local/share/fnm"
export FNM_MULTISHELL_PATH="/Users/jabed/.local/state/fnm_multishells/16501_1721154257393"
export FNM_COREPACK_ENABLED="false"
export FNM_RESOLVE_ENGINES="false"
export FNM_VERSION_FILE_STRATEGY="local"
export FNM_ARCH="arm64"
export FNM_LOGLEVEL="info"
export FNM_NODE_DIST_MIRROR="https://nodejs.org/dist"
rehash

# gpg
export GPG_TTY=$(tty)

# homebrew
HOMEBREW_NO_ENV_HINTS=1

# android sdk
# export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_HOME=~/android
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# react
REACT_EDITOR=zed

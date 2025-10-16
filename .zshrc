# =========================================
#  .zshrc - Optimized and Organized
# =========================================

# -------------------------------
# 1. PATH & Environment
# -------------------------------

# Base PATH additions
export PATH="$HOME/.local/luas/5.1/bin:$HOME/.local/bin:$HOME/.fzf/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/lib/llvm-20/bin:$PATH"

# Remove duplicate PATH entries
typeset -U PATH

# Language & Tools
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

# Editor
export SUDO_EDITOR="nvim"
export EDITOR="nvim"

# Force GTK theme
#export GTK_THEME=Yaru-dark

# Flask debug on
export FLASK_DEBUG=1

# FZF configuration
export FZF_DEFAULT_OPTS="
  --height=60% --layout=reverse --info=inline --border --margin=1 --padding=1
  --style=default
"
export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_R_OPTS="--preview 'echo {}'"
export FZF_ALT_C_OPTS="--preview 'eza -1 --color=always {}'"

# -------------------------------
# 2. Node / NVM
# -------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# -------------------------------
# 3. Zinit (plugin manager)
# -------------------------------
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
### End of Zinit's installer chunk

# -------------------------------
# 3. zsh-vi-mode Config
# -------------------------------
# Increase recursion limit to prevent zle-hook warnings
typeset -g FUNCNEST=200

KEYTIMEOUT=1
ZVM_VI_SURROUND_BINDKEY=s-prefix
ZVM_SYSTEM_CLIPBOARD_ENABLED=true

# Detect platform /  server
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    # WSL
    ZVM_CLIPBOARD_COPY_CMD='win32yank.exe -i --crlf'
    ZVM_CLIPBOARD_PASTE_CMD='win32yank.exe -o --lf'
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    # Windows native
    ZVM_CLIPBOARD_COPY_CMD='win32yank.exe -i --crlf'
    ZVM_CLIPBOARD_PASTE_CMD='win32yank.exe -o --lf'
elif [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    # Linux Wayland
    ZVM_CLIPBOARD_COPY_CMD='wl-copy'
    ZVM_CLIPBOARD_PASTE_CMD='wl-paste'
else
    # Linux X11
    ZVM_CLIPBOARD_COPY_CMD='xclip -selection clipboard'
    ZVM_CLIPBOARD_PASTE_CMD='xclip -selection clipboard -o'
fi

#history keybinds
bindkey -M vicmd 'k' history-search-backward
bindkey -M vicmd 'j' history-search-forward

#load plugin
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# -------------------------------
# 4. Completion & FZF-Tab
# -------------------------------
# Completion styling
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

zinit light zsh-users/zsh-completions
#load completions
autoload -U compinit && compinit

zinit cdreplay -q # recomended for performance?

#source fzf.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Plugins
# Load fzf-tab immediately after compinit
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions

# -------------------------------
# 5. History Configuration
# -------------------------------
HISTSIZE=5000       
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_find_no_dups

zinit snippet OMZP::command-not-found

# -------------------------------
# 6. Aliases
# -------------------------------
[ -f ~/.config/aliases/aliases ] && source ~/.config/aliases/aliases

# yazi cd to directory
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# -------------------------------
# 7 Prompt
# -------------------------------
eval "$(zoxide init zsh --cmd cd)"
eval "$(starship init zsh)"
#zsh-syntax-highlighting last!
zinit light zsh-users/zsh-syntax-highlighting

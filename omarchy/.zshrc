# =========================================
#  .zshrc - Optimized and Organized
# =========================================

# -------------------------------
# 1. PATH & Environment
# -------------------------------

# Base PATH additions
export PATH="$HOME/.local/luas/5.1/bin:$HOME/.local/bin:$HOME/.fzf/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.3.0/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/lib/llvm-20/bin:$PATH"
export PATH="$HOME/.local/scripts:$PATH"
export PATH="$HOME/bin:$PATH"

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/home/emiel/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<

# Perl stuff
PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT

# Remove duplicate PATH entries
typeset -U PATH

# Language & Tools
export JAVA_HOME=/usr/lib/jvm/default
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

# Editor
export SUDO_EDITOR="nvim"
export EDITOR="nvim"
export VISUAL="nvim"

# FZF configuration
# Global defaults
export FZF_DEFAULT_OPTS="--height=60% --style=default"
# Ctrl-T: files & dirs
export FZF_CTRL_T_OPTS="--preview \
'if [[ -d {} ]]; then
   eza -T --level=1 --color=always {}
 elif [[ -f {} ]] && file --mime {} | grep -qv \"charset=binary\"; then
   batcat --color=always --style=numbers --line-range=:500 {}
 else
   file {}
 fi'"
# Ctrl-R: history
export FZF_CTRL_R_OPTS="--preview 'echo {} | batcat --language=sh --style=plain --color=always'"
# Alt-C: directories
export FZF_ALT_C_OPTS="--preview 'eza -T --level=1 --color=always {}'"

source ~/themes/fzf/catppuccin-fzf-mocha.sh

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
typeset -g FUNCNEST=500

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

#load plugin, VI MODE plugin here
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode


# -------------------------------
# 4. Completion & FZF-Tab
# -------------------------------
# Completion styling
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
#set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
#set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
#force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# case insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
#preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
#custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
#To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
#switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# tmux pupup
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
# zinit completions?
zinit light zsh-users/zsh-completions

# poetry completions
fpath+=~/.zfunc

autoload -Uz compinit;  compinit
zinit cdreplay -q # recomended for performance?

# source fzf.zsh
source <(fzf --zsh)

# Plugins
# Load fzf-tab immediately after compinit
zinit light Aloxaf/fzf-tab

# autosuggestions
# prevent rebinding bug
if [[ -z ${_MY_AUTOSUGGEST_LOADED-} ]]; then
  ZSH_AUTOSUGGEST_MANUAL_REBIND=true
  zinit light zsh-users/zsh-autosuggestions
  _MY_AUTOSUGGEST_LOADED=1
fi

# Run after zsh-vi-mode has finished initializing
function zvm_after_init() {
  # 1) Re-run fzf keybindings so vi-mode can't break them
  source <(fzf --zsh)

  # 2) Make <Tab> use fzf-tab again in insert mode
  if (( $+widgets[fzf-tab-complete] )); then
    bindkey -M viins '^I' fzf-tab-complete
  fi

  # 3) Re-bind autosuggestions widgets once after vi-mode + our keybinds
  if (( $+functions[_zsh_autosuggest_bind_widgets] )); then
    _zsh_autosuggest_bind_widgets
  fi

  # 4) Your tmux sessionizer bindings (insert mode)
  bindkey -s '\ef'  'tmux-sessionizer\n'
  bindkey -M vicmd -s '\ef' 'i tmux-sessionizer\n'
  # long running sessions
  bindkey -s '\el' 'tmux-sessionizer -s 0\n'
  bindkey -s '\eo' 'tmux-sessionizer -s 1\n'
  bindkey -s '\ep' 'tmux-sessionizer -s 2\n'
  bindkey -s '\er' 'tmux-sessionizer -s 3\n'
  # normal mode bindings 
  bindkey -M vicmd -s '\el' 'i tmux-sessionizer -s 0\n'
  bindkey -M vicmd -s '\eo' 'i tmux-sessionizer -s 1\n'
  bindkey -M vicmd -s '\ep' 'i tmux-sessionizer -s 2\n'
  bindkey -M vicmd -s '\er' 'i tmux-sessionizer -s 3\n'

  # 5) History search binds in normal mode
  bindkey -M vicmd 'K' history-search-backward
  bindkey -M vicmd 'J' history-search-forward
}


# -------------------------------
# 5. History Configuration
# -------------------------------

HISTSIZE=5000       
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
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
	rm -f -- "$tmp" >/dev/null 2>&1
}


# -------------------------------
# 7 Prompt
# -------------------------------

# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init - zsh)"

eval "$(zoxide init zsh --cmd cd)"

# prevent funcnest
if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi
eval "$(starship init zsh)"

# codex completions
eval "$(codex completion zsh)"

# zsh-syntax-highlighting last!
zinit light zsh-users/zsh-syntax-highlighting


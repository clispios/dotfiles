# export XDG_CONFIG_HOME="$HOME/.config/dotfiles"
PATH="$HOME/Programming/nvim-macos-arm64/bin:$PATH"
PATH="/opt/homebrew/bin:$PATH"
PATH=$(brew --prefix)/opt/findutils/libexec/gnubin:$PATH
PATH="$HOME/.cargo/bin:$PATH"
export EDITOR=nvim
export VISUAL="$EDITOR"
alias vi="nvim"
alias vim="nvim"
alias dircolors="gdircolors"
# export LS_COLORS=…
# zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# if whence dircolors >/dev/null; then
#   export LS_COLORS
#   alias ls='ls --color'
# else
#   export CLICOLOR=1
#   LSCOLORS=…
# fi
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

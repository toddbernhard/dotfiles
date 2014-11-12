source "$ZSH_SRC/aliases.zsh"
source "$ZSH_SRC/key_bindings.zsh"
source "$ZSH_SRC/misc.zsh"
source "$ZSH_SRC/prompt.zsh"

if [ -r "$HOME/local.zshrc" ]; then
  source "$HOME/local.zshrc"
fi

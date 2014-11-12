dir="$(dirname $0)"
source "$dir/aliases.zsh"
source "$dir/key_bindings.zsh"
source "$dir/misc.zsh"
source "$dir/prompt.zsh"

if [ -r "$HOME/local.zshrc" ]; then
  source "$HOME/local.zshrc"
fi

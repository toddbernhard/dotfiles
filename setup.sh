#!/usr/bin/env bash
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

declare -A modules

# To add a module,
#   add a function that does what you want to do
#   add the function name to the "modules" array
#   add a brief description to the "descriptions" array


modules[bin]="symlinks scripts into ~/bin"
bin () {
  # Make ~/bin if needed
  make_dir "$HOME/bin"

  # Symlink all scripts in directory
  for file in $DIR/bin/*; do
    filename=`basename $file`
    target="$HOME/bin/$filename"
    symlink $file $target
  done

  # Add ~/bin to $PATH if needed
  if [[ :$PATH: == *:"$HOME/bin":* || :PATH: == *:"~/bin":* ]]; then
    :
  else
    echo "Warning: ~/bin not on $$PATH"
  fi
}


modules[git]="symlinks ~/.gitconfig, ~/.gitignore_global, sets up local user info"
git_program=`type -P git`

git () {
  program_on_path "git" inner_git
}
inner_git () {
  git_program=`type -P git`

  symlink "$DIR/git/gitconfig" "$HOME/.gitconfig"
  symlink "$DIR/git/gitignore_global" "$HOME/.gitignore_global"
  
  # Setup local user info
  gitlocal="$HOME/.gitconfig.local"
  if [ ! -e "$gitlocal" ]; then
    touch "$gitlocal"
    echo "Created file $gitlocal"
  fi

  if [ ! -f "$gitlocal" -o ! -w "$gitlocal" ]; then
    echo "$gitlocal is not writeable, or is not a normal file."
    echo "Skipping setup of git username and email."
  else
    if ! grep -q "name" "$gitlocal"; then
      echo -ne "\nEnter username for git commits: "
      read username
      "$git_program" config --file "$gitlocal" --add "user.name" "$username"    
    fi
    if ! grep -q "email" "$gitlocal"; then
      echo -ne "\nEnter email for git commits: "
      read email
      "$git_program" config --file "$gitlocal" --add "user.email" "$email"    
    fi

    set_username=`"$git_program" config "user.name"`
    set_email=`"$git_program" config "user.email"`
    echo ""
    echo "Using git user.name=$set_username"
    echo "Using git user.email=$set_email"
    echo ""
  fi
  
  echo ""
  echo "[MANUAL STEPS]"
  echo "    see README.md"
  echo ""
}


modules[tmux]="symlinks ~/.tmux.conf"
tmux () {
  program_on_path "tmux" inner_tmux
}
inner_tmux () {
  symlink "$DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
}


modules[vim]="makes .vim directories, symlinks ~/.vimrc, installs Vundle"
vim_program=`type -P vim`

vim () {
  program_on_path "vim" inner_vim
}
inner_vim () {
  # Create directories
  vimdir="$HOME/.vim"
  make_dir "$vimdir/backup"
  make_dir "$vimdir/bundle"
  make_dir "$vimdir/swp"
  make_dir "$vimdir/undo"

  # Install Vundle
  program_on_path "git" setup_vundle

  # Vimrc
  symlink "$DIR/vim/vimrc" "$HOME/.vimrc"
}
setup_vundle () {
  target="$HOME/.vim/bundle/Vundle.vim"
  if [ ! -e "$target" ]; then
    "$git_program" clone https://github.com/gmarik/Vundle.vim.git "$target"
    "$vim_program" +PluginInstall +qall
    echo "Installed Vundle.vim"
  fi
}


modules[irssi]="symlinks ~/.irssi/config"
irssi () {
  program_on_path "irssi" inner_irssi
}
inner_irssi () {
  make_dir "$HOME/.irssi"
  symlink "$DIR/irssi/config" "$HOME/.irssi/config"
}


modules[zsh]="sources all.zsh - prompt, aliases, keys, more"
zsh () {
  program_on_path "zsh" inner_zsh
}
inner_zsh () {
  zshrc="$HOME/.zshrc"
  if [ -e "$zshrc" ]; then
    if ! grep -q "/all.zsh" "$zshrc"; then
      echo "source $DIR/zsh/all.zsh" >> "$zshrc"
    fi
  else
    echo "no .zshrc"
  fi
}



#####  Util  ##### 

make_dir () {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo "Created directory $1"
  fi
}

symlink () {
  src=$1
  dest=$2

  if [ -e $dest ]; then
    echo "File already exists. Skipping $dest"
  else
    ln -s $src $dest
    echo "Linked $dest"
  fi
}

program_on_path () {
  if type -P "$1" > /dev/null; then
    "$2"
  else
    echo "$1 not found on path. Skipping setup"
  fi
}



#####  Menus  #####

mod_info () {
  printf "%-15s %s" "$1" "${modules[$1]}"
}

show_modules () {
  echo ""
  for mod in "${!modules[@]}"; do
    echo "     `mod_info $mod`"
  done
  echo ""
}

choose_one () {
  show_modules
  PS3="Setup #: "
  select mod in "${!modules[@]}" "< back <"; do
    back_option=$(( ${#modules[@]} + 1))
    if [ ${modules[$mod]+found} ]; then
      setup_one $mod
      break;
    elif [ $back_option == $REPLY ]; then
      break;
    fi
  done
  echo ""
}

setup_all () {
  for mod in "${!modules[@]}"; do
    setup_one $mod
  done
}

setup_one () {
  echo ""
  echo "(${1}) Starting setup"
  eval $1
  echo "(${1}) Setup done"
}

main () {
  cat <<EOF
== Nifty linux toolkit ==

See also manual steps in README.md
EOF

  show_modules

  prompt=$"Pick menu option: "
  PS3=$prompt
  options=("setup all" "setup one" "show all" "< quit <")

  select opt in "${options[@]}"; do 

    case "$REPLY" in

    1 ) setup_all;;
    2 ) choose_one;;
    3 ) show_modules;;

    4 ) echo "Goodbye!"; break;;

    *) echo "Invalid option. Try another one.";continue;;

    esac
    PS3=$prompt

  done
  
  exit 0
}

main

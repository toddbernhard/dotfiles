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


modules[git]="symlinks ~/.gitconfig, ~/.gitignore_global"
git () {
  program_on_path "git" inner_git
}
inner_git () {
  symlink "$DIR/git/gitconfig" "$HOME/.gitconfig"
  symlink "$DIR/git/gitignore_global" "$HOME/.gitignore_global"
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


modules[vim]="makes .vim directories, symlinks ~/.vimrc"
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

  #
  #if [ type "git" > /dev/null ]; then
  #  current_dir=`pwd`
  #  cd "$vimdir/bundle"
  #  git c
  #fi
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
  if type "$1" > /dev/null; then
    "$2"
  else
    "$1 not found on path. Skipping setup"
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
  PS3="Setup tool: "
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

## Installation

[`setup.sh`](./setup.sh) will interactively setup/symlink files for [`git`](./git), [`tmux`](./tmux), [`vim`](./vim) and [`bin/`](./bin).

#### Additional manual setup

###### ssh client
- setup client RSA keys (often github, home, office)
- add common destinations to `~/.ssh/config` (see [Arch wiki](https://wiki.archlinux.org/index.php/Secure_Shell#Saving_connection_data_in_ssh_config))

###### sshd server
- create group -- `sudo groupadd ssh`
- create users if necessary
- add users to group -- `sudo usermod -a --groups ssh <username>`
- `sshd_config` edits:
  - `AllowGroups ssh`
  - `PasswordAuthentication no`

###### git
- upload ssh key to github
- add `user.name`, `user.email` to `~/local.gitconfig`

###### vim
- `git clone git@github.com:gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim`
- inside vim `:BundleInstall`

###### zsh
- create `~/.zshrc`
  - `export ZSH_SRC=<path/to/dotfiles/zsh>`
  - `source $ZSH_SRC/all.zsh`
- change login shell in `/etc/passwd`

###### irssi
- symlink: `ln -s <checkout>/irssi/config ~/.irssi/config`

###### ack
- http://beyondgrep.com/install/

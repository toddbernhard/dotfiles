## Installation

[`setup.sh`](./setup.sh) will optionally configure [`git`](./git), [`irssi`](./irssi), [`tmux`](./tmux), [`vim`](./vim), [`zsh`](./zsh) and [`~/bin/`](./bin).

#### Additional manual setup

###### ssh client
- setup client RSA keys (often github, home, office)
- add common destinations to `~/.ssh/config` (see [Arch wiki](https://wiki.archlinux.org/index.php/Secure_Shell#Saving_connection_data_in_ssh_config))
- upload key to github

###### sshd server
- create group -- `sudo groupadd ssh`
- create users if necessary
- add users to group -- `sudo usermod -a --groups ssh <username>`
- `sshd_config` edits:
  - `AllowGroups ssh`
  - `PasswordAuthentication no`

###### zsh
- change login shell in `/etc/passwd`

###### ag
- install ag -- the [silver searcher](https://github.com/ggreer/the_silver_searcher)

## License & Credits
The vim color scheme Tomorrow Night is from Chris Kempson's [Tomorrow Theme](https://github.com/chriskempson/tomorrow-theme), under the [MIT License](https://github.com/toddbernhard/dotfiles/blob/master/vim/tomorrow-theme/LICENSE.md). It is bundled for easy installation.
The rest is a mismatch of pilfered dotfiles from around net. It is [Unlicensed](https://github.com/toddbernhard/dotfiles/blob/master/UNLICENSE.txt) and part of the public domain.

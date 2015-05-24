## Installation

[`setup.sh`](./setup.sh) will optionally configure [`git`](./git), [`irssi`](./irssi), [`tmux`](./tmux), [`vim`](./vim), [`zsh`](./zsh) and [`bin/`](./bin) (scripts).

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

###### zsh
- create `~/.zshrc`
- change login shell in `/etc/passwd`

###### ack
- http://beyondgrep.com/install/

## Installation

[`setup.sh`](./setup.sh) will optionally configure [`git`](./git), [`irssi`](./irssi), [`tmux`](./tmux), [`vim`](./vim), [`zsh`](./zsh) and [`~/bin/`](./bin).

#### Additional manual setup

###### keymap
- set to dvorak
- bind capslock to escape
  - http://askubuntu.com/questions/363346/how-to-permanently-switch-caps-lock-and-esc
  - https://bbs.archlinux.org/viewtopic.php?id=100007

###### zsh
- change login shell in `/etc/passwd`

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

###### ag
- install ag -- the [silver searcher](https://github.com/ggreer/the_silver_searcher)

## License & Credits
Most of this is lifted from tutorials, tips, and dotfiles from around the net. A few 3rd-party artifacts are bundled here for easy installation:
- Tomorrow Night, the vim color scheme from Chris Kempson's [Tomorrow Theme](https://github.com/chriskempson/tomorrow-theme). It is available under the [MIT License](https://github.com/toddbernhard/dotfiles/blob/master/vim/tomorrow-theme/LICENSE.md).
- Badwolf, the vim color scheme from [Steve Losh](http://stevelosh.com/projects/badwolf). It is available under the [MIT License](https://github.com/toddbernhard/dotfiles/blob/master/vim/badwolf-theme/LICENSE.md).
The rest is [Unlicensed](https://github.com/toddbernhard/dotfiles/blob/master/UNLICENSE.txt).

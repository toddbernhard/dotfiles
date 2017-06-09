Easy setup for CLI tools on a new install.

---

## Pre-Installation for Clean System (optional)

Install `git` and `xclip`, then run

```
ssh-keygen -q -b 4096 -t rsa -f ~/.ssh/github.id_rsa -N ""

cat << EOF >> ~/.ssh/config
Host github
  HostName github.com
  IdentityFile ~/.ssh/github.id_rsa
EOF

xclip -selection c ~/.ssh/github.id_rsa.pub
```

Add your SSH key (copied to X's clipboard) to [your Github account](https://github.com/settings/keys). Then

```
git clone git@github:toddbernhard/dotfiles.git
```

---

## Installation

[`setup.sh`](./setup.sh) will optionally configure [`git`](./git), [`irssi`](./irssi), [`tmux`](./tmux), [`vim`](./vim), [`zsh`](./zsh) and [`~/bin/`](./bin).

#### Additional manual setup

###### keymap
- set to dvorak
- bind capslock to escape
  - xkeyboard-config option is `caps:escape`
  - http://askubuntu.com/questions/363346/how-to-permanently-switch-caps-lock-and-esc
  - https://bbs.archlinux.org/viewtopic.php?id=100007

###### zsh
- change login shell in `/etc/passwd`
- change terminal emulator shell to `/bin/zsh`

###### terminal
- I recommend the Base-16 Twilight theme. Run `./terminal/base16-twilight.sh` to add it to Gnome terminal.

###### fonts
- Droid Sans, Droid Sans Mono, Droid Sans Bold are all included in [fonts/droid-sans](https://github.com/toddbernhard/dotfiles/blob/master/fonts/droid-sans).

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

---

## License & Credits
Most of this is lifted from tutorials, tips, and dotfiles from around the net. A few 3rd-party artifacts are bundled here for easy installation:

- Tomorrow Night, the vim color scheme from Chris Kempson's [Tomorrow Theme](https://github.com/chriskempson/tomorrow-theme). It is available under the [MIT License](https://github.com/toddbernhard/dotfiles/blob/master/vim/tomorrow-theme/LICENSE.md).
- Badwolf, the vim color scheme from [Steve Losh](http://stevelosh.com/projects/badwolf). It is available under the [MIT License](https://github.com/toddbernhard/dotfiles/blob/master/vim/badwolf-theme/LICENSE.markdown).
- Gnome Terminal themes from the [Base-16 theme templating project](http://chriskempson.com/projects/base16/). The terminal scripts are maintained by [Aaron Williamson](https://github.com/aaron-williamson/base16-gnome-terminal) and are available under the [MIT License](https://github.com/toddbernhard/dotfiles/blob/master/terminal/License.txt).

The rest is [Unlicensed](https://github.com/toddbernhard/dotfiles/blob/master/UNLICENSE.txt).

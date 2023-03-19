Scripted setup of some tools.

---

### Clean system? Start here

Install `git`, then run

```
# Create GitHub SSH key. See bin/ssh-keygen-rsa
ssh-keygen -t ed25519 -q -N "" -f ~/.ssh/github.id_ed25519

# Add github alias to ssh/config
cat << EOF >> ~/.ssh/config
Host github
  HostName github.com
  IdentityFile ~/.ssh/github.id_ed25519
EOF
chmod 600 ~/.ssh/config

# Show the public key
cat ~/.ssh/github.id_ed25519.pub
```

Add your SSH key to [your Github account](https://github.com/settings/keys). Then

```
git clone git@github:toddbernhard/dotfiles.git
```

---

## Installation

[`setup.py`](./setup.py) does the magic.
```
    bin         symlinks scripts into ~/bin
    firefox     installs extensions, user.js settings, and userChrome styles
    fonts       installs Droid Sans [+Bold,+Mono] on OSX only
    git         symlinks ~/.gitconfig, ~/.gitignore_global, sets up local user info
    macos       prompts to install common apps, brew apps, and OS defaults
    tmux        symlinks ~/.tmux.conf
    vim         makes .vim directories, symlinks ~/.vimrc, installs Vundle
    zsh         sources all.zsh - prompt, aliases, keys, more
```

#### Additional manual setup

###### keymap
- set to dvorak
- bind capslock to escape

###### Colors
- I like the [Tinted Theming project](https://github.com/tinted-theming/home) based on [Base16](https://github.com/chriskempson/base16).
- Get your iTerm2 themes here: [https://github.com/tinted-theming/base16-iterm2](https://github.com/tinted-theming/base16-iterm2)
    - `base16-tokyo-city-terminal-dark` is a good start
    - `base16-summerfruit-dark` is juicy

###### ssh client
- setup client keys (often github, home, office)
- add common destinations to `~/.ssh/config` (see [Arch wiki](https://wiki.archlinux.org/index.php/Secure_Shell#Saving_connection_data_in_ssh_config))
- upload key to github

###### sshd server
- create group -- `sudo groupadd ssh`
- create users if necessary
- add users to group -- `sudo usermod -a --groups ssh <username>`
- `sshd_config` edits:
  - `AllowGroups ssh`
  - `PasswordAuthentication no`


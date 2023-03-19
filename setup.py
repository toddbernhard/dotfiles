#!/usr/bin/env python3

import configparser
import json
import os
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Optional


home = Path.home()
dotdir = Path(__file__).resolve().parent


@dataclass
class Module:
    name: str
    description: str
    setup: Callable[[], None]



def setup_bin():
    # Make ~/bin if needed
    make_dir(home / 'bin')

    # Symlink all scripts in director
    for file in dotdir.glob('bin/*'):
        symlink(home / 'bin' / file.name, file)

    execute_path = os.environ.get('PATH')
    if '~/bin' not in execute_path and str(home) not in execute_path:
        print('Warning: ~/bin not on $PATH')


def setup_firefox():

    def find_firefox_dir() -> Path:
        # docs https://kb.mozillazine.org/Profile_folder_-_Firefox

        possible_config_dirs = [
            home / 'Library' / 'Application Support' / 'Firefox',  # osx
            home / 'Library' / 'Mozilla' / 'Firefox',              # osx
            home / '.mozilla' / 'firefox'                          # linux
        ]

        if 'APPDATA' in os.environ:                                # windows
            possible_config_dirs.append(Path(os.getenv('APPDATA')) / 'Mozilla' / 'Firefox')

        config_dirs = [d for d in possible_config_dirs if d.exists()]
        return next(iter(config_dirs), None)


    def parse_profiles_ini(config_dir: Path) -> Optional[str]:
        profiles_ini = configparser.ConfigParser()
        profiles_ini.read(config_dir / 'profiles.ini')

        # docs on Locked=1 https://support.mozilla.org/en-US/questions/1276002
        selected_profile = [
            section
            for section in profiles_ini.sections()
            for item in profiles_ini.items(section)
            if item == ('locked', '1')
        ]

        if len(selected_profile) != 1:
            profiles = '\n'.join(selected_profile)
            print(f'Expected exactly one profile to have the item "Locked=1". Instead found: \n{profiles}')
            exit (3)
        else:
            selected_profile = selected_profile[0]

        print(f'Looking at profiles.ini, the profile with Locked=1 is: {selected_profile}')
        return profiles_ini[selected_profile]['Default']


    def parse_user_js(text: str) -> dict:
        sections = [x.strip() for x in template_user.split('\n\n')]
        results = {}
        for section in sections:
            lines = section.split('\n')
            setting = lines[-1].removeprefix('user_pref("').split('"', 1)[0]
            results[setting] = dict()
            results[setting]['question'] = lines[0].removeprefix('// ')
            results[setting]['lines'] = lines[1:]
        return results


    print('This is a work in progress, only tested on OSX, and likely contains untested pieces.')
    input('Hit enter to proceed ... ')
    print('')

    config_dir = find_firefox_dir()

    if not config_dir:
        print(f'Could not resolve the Firefox application data directory.'
               'Either the script is broken or you need to install Firefox.\n'
               'See https://www.mozilla.org/en-US/firefox/')
        exit(4)
    else:
        print(f'Found {config_dir}. Using it for the remaining work.')

    profile_path = parse_profiles_ini(config_dir)
    profile_path = config_dir / profile_path
    print(f'Parsed profile path: {profile_path}\n')

    if ask_yes_no('Setup extensions?', default=True):
        recommended = None
        with open(dotdir / 'firefox' / 'recommended-extensions.json', 'r') as file:
            recommended = json.load(file)

        current = None
        with open(profile_path / 'extensions.json', 'r') as file:
            current = json.load(file)
        current = [x['id'] for x in current['addons']]

        for rec in recommended.keys():
            name = recommended[rec]['name']
            if rec in current:
                print(f'Already installed extension. Skipping {name}')
            else:
                if ask_yes_no(f"Add {name}?", default=recommended[rec].get('default', False)):
                    subprocess.run(['open', recommended[rec]['url']])
        print('')

    if ask_yes_no('Setup userChrome.css?'):

        current_extensions = None
        with open(profile_path / 'extensions.json', 'r') as file:
            current_extensions = json.load(file)
        current_extensions = [x['id'] for x in current_extensions['addons']]

        tree_tab_extensions = (ext_id for ext_id in current_extensions if 'treestyletab' in ext_id)
        is_safe_to_hide_tab_bar = bool(next(tree_tab_extensions, False))

        if not is_safe_to_hide_tab_bar:
            is_safe_to_hide_tab_bar = ask_yes_no('This will hide the tab bar. It is recommended '
                                                 'to install a tab bar extension before doing this.'
                                                 ' Do you want to proceed?')

        if is_safe_to_hide_tab_bar:
            make_dir(profile_path / 'chrome')
            chrome_path = profile_path / 'chrome' / 'userChrome.css'
            copy(dotdir / 'firefox' / 'template-profile' / 'chrome' / 'userChrome.css', chrome_path)
        else:
            print('Skipping chrome/userChrome.css')
        print('')

    if ask_yes_no('Setup user.js?'):
        user_js = profile_path / 'user.js'
        touch_file(user_js)

        user_js_text = None
        with open(user_js, 'r') as file:
            user_js_text = file.read()

        template_user = None
        with open(dotdir / 'firefox' / 'template-profile' / 'user.js', 'r') as file:
            template_user = file.read()

        template = parse_user_js(template_user)

        lines = []
        shown_warning = False
        def show_warning():
            nonlocal shown_warning
            if not shown_warning:
                print(f'\n'
                      f'=======================================================================\n'
                      f'Warning: changes to user.js are copied to pref.js on every startup.\n'
                      f'They can only be undone by editing or removing user_js. File location:\n'
                      f'    {user_js}\n'
                      f'=======================================================================\n')
                shown_warning = True

        for setting in template.keys():

            if not setting in user_js_text:
                show_warning()
                if ask_yes_no(template[setting]['question'] + '?', default=True):
                    lines.append(f'// {template[setting]["question"]}?')
                    lines.extend(template[setting]['lines'])
            else:
                print(f'Already set. Skipping {setting}')

        if shown_warning:
            print('') # Create some space

        if lines:
            with open(user_js, 'a') as file:
                joined = '\n'.join(lines)
                file.write('\n' + joined)
                print(f'Added to {user_js}:\n{joined}')


def setup_fonts():
    if sys.platform == 'darwin':
        for font in dotdir.glob('fonts/**/*.ttf'):
            copy(font, home / 'Library' / 'Fonts' / font.name)
    else:
        print('Font installation only scripted for OSX.')


def setup_git():
    if is_program_on_path('git'):
        symlink(home / '.gitconfig', dotdir / 'git' / 'gitconfig')
        symlink(home / '.gitignore_global', dotdir / 'git' / 'gitignore_global')

        gitlocal = home / '.gitconfig.local'
        touch_file(gitlocal)

        gitlocal_text = None
        with open(gitlocal, 'r') as file:
            gitlocal_text = file.read()

        if 'name' not in gitlocal_text:
            username = input('\nEnter an username for git commits [enter nothing to skip]: ')
            if username:
                subprocess.run(['git', 'config', '--file', str(gitlocal), '--add', 'user.name', username])
        if 'email' not in gitlocal_text:
            email = input('\nEnter an email for git commits [enter nothing to skip]: ')
            if email:
                subprocess.run(['git', 'config', '--file', str(gitlocal), '--add', 'user.email', email])


        using_username = run_get_output('git', 'config', 'user.name')
        using_email = run_get_output('git', 'config', 'user.email')
        print(f'Using git user.name={using_username}')
        print(f'Using git user.email={using_email}')


def setup_macos():
    if sys.platform != 'darwin':
        print('MacOS settings only make sense for Macs')
        exit(5)

    if ask_yes_no('Prompt to install brew things?'):
        print('')
        if is_program_on_path('brew'):
            recommended = None
            with open(dotdir / 'macos' / 'brew-install-these.txt', 'r') as file:
                recommended = file.read()
            recommended = [x.strip() for x in recommended.split('\n') if x.strip()]

            to_install = []

            for item in recommended:
                item = item.removeprefix('brew install ')
                if item.startswith('#') or item.startswith('//'):
                    print(item)
                else:
                    if ask_yes_no(f'Install {item}?'):
                        to_install.append(item)

            if to_install:
                print(f'\nRunning: brew install {" ".join(to_install)}\n')
                print('########################################')
                subprocess.run(['brew', 'install'] + to_install)
                print('########################################\n')

        elif ask_yes_no('Open brew.sh to begin installing brew?', default=True):
            subprocess.run(['open', 'https://brew.sh/'])

    if ask_yes_no('Prompt to install applications?'):
        print('')
        installed_apps = run_get_output('mdfind', 'kMDItemKind == "Application"')

        recommended_apps = None
        with open(dotdir / 'macos' / 'recommended-apps.json', 'r') as file:
            recommended_apps = json.load(file)

        for app in recommended_apps.keys():
            if app in installed_apps:
                print(f'{app} already installed, skipping.')
            elif ask_yes_no(f'Open {recommended_apps[app]} to install {app}?'):
                subprocess.run(['open', recommended_apps[app]])
        print('')

    if ask_yes_no('Prompt to configure MacOS defaults?'):
        print('')

        recommended_defaults = None
        with open(dotdir / 'macos' / 'recommended-defaults.json', 'r') as file:
            recommended_defaults = json.load(file)

        for setting in recommended_defaults.keys():
            if recommended_defaults[setting]['enabled']:
                current = run_get_output('defaults', 'read', *setting.split(' '), include_stderr=True)

                if 'does not exist' in current:
                    if ask_yes_no(f'{recommended_defaults[setting]["comment"]} ?'):
                        for command in recommended_defaults[setting]['commands']:
                            print(command)
                            output = run_get_output(*command.split(' '))
                            if output:
                                print(output)
                else:
                    print(f'Already set. Skipping. Currently: "defaults read {setting}" => {current}')
        print('')


def setup_tmux():
    if is_program_on_path('tmux'):
        symlink(home / '.tmux.conf', dotdir / 'tmux' / 'tmux.conf')


def setup_vim():
    if is_program_on_path('vim'):
        vimdir = home / '.vim'
        make_dir(vimdir / 'backup')
        make_dir(vimdir / 'bundle')
        make_dir(vimdir / 'colors')
        make_dir(vimdir / 'swp')
        make_dir(vimdir / 'undo')

        symlink(home / '.vimrc', dotdir / 'vim' / 'vimrc')

        symlink(vimdir / 'colors' / 'badwolf.vim', dotdir / 'vim' / 'badwolf-theme' / 'badwolf.vim')
        symlink(vimdir / 'colors' / 'jellybeans.vim', dotdir / 'vim' / 'jellybeans-theme' / 'jellybeans.vim')

        if is_program_on_path('git'):
            target = vimdir / 'bundle' / 'Vundle.vim'
            if not target.exists():
                subprocess.run(['git', 'clone', 'https://github.com/gmarik/Vundle.vim.git', str(target)])
                subprocess.run(['vim', '+PluginInstall', '+qall'])
                print('Installed Vundle.vim')


def setup_zsh():
    if is_program_on_path('zsh'):

        zshrc = home / '.zshrc'
        touch_file(zshrc)

        zshrc_text = None
        with open(zshrc, 'r') as file:
            zshrc_text = file.read()

        lines = []
        if 'ZSH_SRC' in zshrc_text:
            print('ZSH_SRC already set')
        else:
            lines.append(f'# Setup custom prompt\nexport ZSH_SRC={dotdir}/zsh')

        if 'PROMPT_HOST' not in zshrc_text:
            host_symbol = input('Enter a host symbol (leave blank for hostname): ')
            if host_symbol:
                lines.append(f'export PROMPT_HOST={host_symbol}')

        if '/all.zsh' in zshrc_text:
            print('all.zsh already sourced')
        else:
            lines.append(f'source {dotdir}/zsh/all.zsh')

        if lines:
            with open(zshrc, 'a') as file:
                joined = '\n'.join(lines)
                file.write('\n' + joined)
                print(f'\nAdded to .zshrc:\n{joined}')

        if sys.platform == 'darwin':
            shell = run_get_output('dscl', '.', '-read', home, 'UserShell').removeprefix('UserShell: ')
            if shell == '/bin/zsh':
                print('Login shell set to /bin/zsh. All set.')
            else:
                print(f'WARNING! login shell set to {shell}. Update if you want.')
        else:
            print('WARNING! Login shell only scripted on OSX. '
                  'Check that your login shell is set to /bin/zsh.')


modules = [
    Module(
        name='bin',
        description='symlinks scripts into ~/bin',
        setup=lambda: setup_bin()
    ),
    Module(
        name='firefox',
        description='installs extensions, user.js settings, and userChrome styles',
        setup=lambda: setup_firefox()
    ),
    Module(
        name='fonts',
        description='installs Droid Sans [+Bold,+Mono] on OSX only',
        setup=lambda: setup_fonts()
    ),
    Module(
        name='git',
        description='symlinks ~/.gitconfig, ~/.gitignore_global, sets up local user info',
        setup=lambda: setup_git()
    ),
    Module(
        name='macos',
        description='prompts to install common apps, brew apps, and OS defaults',
        setup=lambda: setup_macos()
    ),
    Module(
        name='tmux',
        description='symlinks ~/.tmux.conf',
        setup=lambda: setup_tmux()
    ),
    Module(
        name='vim',
        description='makes .vim directories, symlinks ~/.vimrc, installs Vundle',
        setup=lambda: setup_vim()
    ),
    Module(
        name='zsh',
        description='sources all.zsh - prompt, aliases, keys, more',
        setup=lambda: setup_zsh()
    )
]


# Building blocks for setups

def ask_yes_no(question: str, default: bool = False) -> bool:
    print(question)
    response = None
    if default:
        response = input('Y/n: ')
        response = response not in ['n', 'N', 'no', 'No']
    else:
        response = input('y/N: ')
        response = response in ['y', 'Y', 'yes', 'Yes']
    return response


def make_dir(path):
    try:
        path.mkdir(parents=True)
    except FileExistsError:
        return False

    print(f'Created directory {path}')
    return True


def touch_file(path: Path):
    if not path.exists():
        path.touch()
        print(f'Created {path}')


def symlink(src, target):
    if src.exists() or src.is_symlink():
        print(f'File already exists. Skipping {src}')
    else:
        src.symlink_to(target)
        print(f'Linked {target}')


def copy(src, target):
    if target.exists():
        print(f'File already exists. Skipping {src}')
    else:
        shutil.copy(src, target)
        print(f'Copied to {target}')


def is_program_on_path(name) -> bool:
    exists = bool(shutil.which(name))
    if not exists:
        print(f'{name} not found on path. Skipping setup of {name}.')
    return exists


def run_get_output(*args, include_stderr=False):
    process = None
    if include_stderr:
        process = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    else:
        process = subprocess.run(args, stdout=subprocess.PIPE, text=True)
    return process.stdout.strip()

# Interactive menu pieces

def is_python_ok() -> bool:
    return sys.version_info[0] == 3 and sys.version_info[1] >= 5


def show_menu():
    print('Select a tool to setup:\n')
    for m in modules:
        print(f'    {m.name:12}{m.description}')
    print('')

    for index, m in enumerate(modules):
        print(f'{index+1}) {m.name}')
    print('')


def get_choice() -> int:
    try:
       choice = int(input('Setup #: '))
       print('')
    except ValueError:
        choice = 0

    if choice < 1 or choice > len(modules):
        choice = 0

    return choice


if __name__ == "__main__":

    if not is_python_ok():
        print('min version python 3.5')
        exit(1)

    show_menu()
    choice = get_choice()

    if not choice:
        print('invalid selection')
        exit(2)

    modules[choice-1].setup()

    print('\nSee also the manual setup steps described in the README.')


#!/usr/bin/env python

import argparse
import logging
from pathlib import Path
import platform
import subprocess

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

profiles_path = Path.home() / 'Library' / 'Application Support' / 'Firefox' / 'Profiles'
firefox_path = '/Applications/Firefox.app/Contents/MacOS/firefox'

if platform.system() != 'Darwin':
    logger.warning('This script has only been tested on MacOS. The paths (and maybe more) will need to be adapted'
                   'for other OSs.')


def create_profile(args):
    if next(profiles_path.glob('*.' + args.profile_name), None):
        logger.error(f'Firefox profile {args.profile_name} already exists')
        exit(1)

    cmd = f'{firefox_path} -CreateProfile {args.profile_name}'
    logger.warning(cmd)
    subprocess.run(args=cmd, shell=True, check=True)

    profile_path = profiles_path.glob(f'*.{args.profile_name}')
    profile_path = next(profile_path)

    (profile_path / 'chrome').mkdir()


def create_macos_launcher(args):
    app_name = f'{args.profile_name}.app'
    base_path = Path.cwd() / app_name
    info_plist_path = base_path / 'Contents' / 'Info.plist'
    macos_path = base_path / 'Contents' / 'MacOS'
    executable_path = macos_path / args.profile_name

    # Check that we should start
    if base_path.exists():
        logger.error(f'{base_path} already exists')
        exit(1)

    # Create directories
    for directory in [macos_path]:
        directory.mkdir(parents=True, exist_ok=False)

    # Create Info.plist
    with info_plist_path.open('w') as f:
        f.write(f"""
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>{args.profile_name}</string>
    <key>CFBundleIdentifier</key>
    <string>com.mozilla.firefox.{args.profile_name.replace(' ', '')}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleExecutable</key>
    <string>{args.profile_name}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
</dict>
</plist>
""")

    # Create executable Bash script
    with executable_path.open('w') as f:
        f.writelines([
            '#!/bin/bash\n',
            f'{firefox_path} -new-instance -P {args.profile_name} {args.home}'
        ])
    executable_path.chmod(0o755)


if __name__ == '__main__':
    main_parser = argparse.ArgumentParser(prog='create-firefox.py')
    subparsers = main_parser.add_subparsers(metavar='command', title='Available actions', required=True)

    profile_parser = subparsers.add_parser('profile', help='Create a new Firefox profile')
    profile_parser.add_argument('profile_name', help='The name of the profile to create')
    profile_parser.set_defaults(handler=create_profile)

    launcher_parser = subparsers.add_parser('launcher', help='Create a launcher for a Firefox profile')
    launcher_parser.add_argument('profile_name', help='The name of the profile to create')
    launcher_parser.add_argument('--home', help='Set the opening page')
    launcher_parser.set_defaults(handler=create_macos_launcher)


    #create_macos_launcher('another', 'https://www.google.com')
    args = main_parser.parse_args()

    if hasattr(args, 'handler'):
        args.handler(args)

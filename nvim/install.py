#!/usr/bin/env python3
# Installs/updates Neovim config files.
# Run from this folder.

import argparse
import filecmp
import logging
from pathlib import Path
import shutil
import subprocess
import sys


def eprint(*args, **kwargs):
    return print(*args, file=sys.stderr, **kwargs)


def copyfile(source_path, target_path, *, follow_symlinks=True):
    logging.info(f'Copying {source_path} to {target_path}'
                 f'{" (overwriting)" if target_path.exists() else ""}...')
    shutil.copyfile(source_path, target_path, follow_symlinks=follow_symlinks)


def confirm(prompt='(y/n) '):
    while not (choice := input(prompt).lower()) or choice[0] not in 'yn':
        if choice:
            eprint(f'Invalid choice: {choice}')
    return True if choice == 'y' else False


def main():
    parser = argparse.ArgumentParser(
        prog='install.py',
        description='Installs/updates Neovim configuration files'
    )
    parser.add_argument('-q', '--quiet', action='store_true',
                        help='silence output messages')
    parser.add_argument('-Y', '--confirm-all', action='store_true',
                        help="don't ask whether or not to overwrite files")
    args = parser.parse_args()

    loglevel = logging.ERROR if args.quiet else logging.INFO
    logging.basicConfig(format='%(message)s', level=loglevel,
                        stream=sys.stderr)

    nvim_binary = shutil.which('nvim')
    if not nvim_binary:
        logging.error('Error: Unable to locate nvim binary')
        return 1

    get_config_dir_cmd = [nvim_binary, '--headless', '--clean', '-c',
                          'echo stdpath("config") | q']
    nvim_output = subprocess.run(get_config_dir_cmd, capture_output=True)
    nvim_config_dir = Path(nvim_output.stderr.decode('utf-8'))
    if not nvim_config_dir.exists():
        logging.info(f'Creating Neovim config directory')
        nvim_config_dir.mkdir(mode=0o755, parents=True)

    staged_config_files = Path('.').glob('**/*.lua')
    for file_path in staged_config_files:
        target_path = nvim_config_dir / file_path
        if target_path.exists():
            if not filecmp.cmp(file_path, target_path, shallow=False):
                if args.confirm_all:
                    copyfile(file_path, target_path)
                else:
                    print(f'Overwrite {target_path} with {file_path}?')
                    if confirm():
                        copyfile(file_path, target_path)
                    else:
                        logging.info('Skipping...')
            else:
                logging.info(f'{target_path} unchanged, skipping...')
        else:
            parent_dir = target_path.parents[0]
            if not parent_dir.exists():
                logging.info(f'Creating directories for {target_path}...')
                parent_dir.mkdir(mode=0o755, parents=True)
            copyfile(file_path, target_path)

    return 0


if __name__ == '__main__':
    sys.exit(main())

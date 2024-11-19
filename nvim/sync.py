#!/usr/bin/env python3
# Installs/synchronizes Neovim config files.
# Run from this folder.

import argparse
import filecmp
from itertools import chain
import logging
from pathlib import Path
import shutil
import subprocess
import sys


class SyncException(Exception):
    pass

class Neovim:
    def __init__(self):
        self.nvim = shutil.which('nvim')
        if not self.nvim:
            raise SyncException('Error: Unable to locate nvim binary')

        self.config_path = Path(self.run('echo stdpath("config") | q',
                                         nvim_args=('--clean',)))
        self.data_path = Path(self.run('echo stdpath("data") | q',
                                       nvim_args=('--clean',)))
        self.packer_path = self.data_path / 'site' / 'pack' / 'packer'

        if not self.config_path.exists():
            logging.info(f'Creating Neovim config directory')
            self.config_path.mkdir(mode=0o755, parents=True)
        if not self.data_path.exists():
            logging.info(f'Creating Neovim data directory')
            self.data_path.mkdir(mode=0o755, parents=True)

    def run(self, *cmds, nvim_args=None, ignore_output=False):
        if not isinstance(nvim_args, (tuple, list)):
            nvim_args = (nvim_args,) if isinstance(nvim_args, str) else ()
        nvim_args = ('--headless', *nvim_args)
        nvim_cmds = chain.from_iterable(('-c', cmd) for cmd in cmds)

        subprocess_kwargs = {}
        if not ignore_output:
            subprocess_kwargs['stdout'] = subprocess.PIPE
            subprocess_kwargs['stderr'] = subprocess.STDOUT
            subprocess_kwargs['text'] = True

        output = subprocess.run((self.nvim, *nvim_args, *nvim_cmds),
                                **subprocess_kwargs)
        if output.returncode != 0:
            log_and_throw(f'exit code {output.returncode} when running '
                          f'{self.nvim} {nvim_args} {nvim_cmds}')
        return output.stdout

    def install_packer(self):
        logging.info(f'Installing packer.nvim...')
        git_path = shutil.which('git')
        if not git_path:
            log_and_throw('unable to locate git binary')

        repo_url = 'https://github.com/wbthomason/packer.nvim'
        target_dir = self.packer_path / 'start' / 'packer.nvim'
        git_cmd = ('git', 'clone', '--depth', '1', repo_url, str(target_dir))
        result = subprocess.run(git_cmd, capture_output=True)
        if result.returncode != 0:
            log_and_throw('error cloning git repo')

        # if we run :PackerCompile and :qa in succession, neovim will exit
        # before the first command finishes. if we don't :qa, the process hangs
        # indefinitely. apparently, packer implements autocmd triggers that
        # fire after certain tasks finish, which is what we use here to solve
        # this issue (see :help packer-user-autocmds)
        autoquit = 'autocmd User PackerComplete qa'
        self.run(autoquit, 'PackerInstall', ignore_output=True)

    def packer_compile(self):
        if not self.packer_dir.exists():
            self.install_packer()

        autoquit = 'autocmd User PackerCompileDone qa'
        self.run(autoquit, 'PackerCompile', ignore_output=True)

    def push_config(self, args):
        updated_files = []
        for file_path in Path(__file__).parent.glob('**/*.lua'):
            target_path = self.config_path / file_path
            if target_path.exists():
                if not filecmp.cmp(file_path, target_path, shallow=False):
                    prompt = (f'{target_path} differs from {file_path}. '
                              'Overwrite? (y/n) ')
                    if args.force or confirm(prompt=prompt):
                        copyfile(file_path, target_path)
                        updated_files.append(target_path)
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
                updated_files.append(target_path)

        if any(p.name == 'plugins.lua' for p in updated_files):
            logging.info('plugins.lua updated, recompiling packer cache...')
            self.packer_compile()

    def pull_config(self, args):
        raise NotImplementedError


def log_and_throw(msg: str):
    logging.error(f'Error: {msg}')
    raise SyncException(msg)

def copyfile(source_path, target_path, *, follow_symlinks=True):
    logging.info(f'Copying {source_path} to {target_path}'
                 f'{" (overwriting)" if target_path.exists() else ""}...')
    shutil.copyfile(source_path, target_path, follow_symlinks=follow_symlinks)

def confirm(prompt='(y/n) ', options='yn'):
    while not (choice := input(prompt).lower()) or choice[0] not in options:
        if choice:
            print(f'Invalid choice: {choice}', file=sys.stderr)
    return True if choice == 'y' else False

def main():
    nvim = Neovim()

    parser = argparse.ArgumentParser(
        prog='sync.py',
        description='Installs/synchronizes Neovim configuration files'
    )
    parser.add_argument('-q', '--quiet', action='store_true',
                        help='silence output messages')
    parser.add_argument('-F', '--force', action='store_true',
                        help="don't ask whether or not to overwrite files")

    subparsers = parser.add_subparsers(required=True)
    push_parser = subparsers.add_parser(
        'push',
        help='copy files from this repository into the local config directory'
    )
    push_parser.set_defaults(func=nvim.push_config)
    pull_parser = subparsers.add_parser(
        'pull',
        help='copy files from the local config directory into this repository'
    )
    pull_parser.set_defaults(func=nvim.pull_config)

    args = parser.parse_args()
    loglevel = logging.ERROR if args.quiet else logging.INFO
    logging.basicConfig(format='%(message)s', level=loglevel,
                        stream=sys.stderr)
    args.func(args)

    return 0

if __name__ == '__main__':
    sys.exit(main())

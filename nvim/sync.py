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

        self.repo_path = Path(__file__).parent
        self.config_path = Path(self.run('echo stdpath("config") | q',
                                         nvim_args=('--clean',)))
        self.data_path = Path(self.run('echo stdpath("data") | q',
                                       nvim_args=('--clean',)))
        self.packer_path = self.data_path / 'site' / 'pack' / 'packer'

        if not self.config_path.exists():
            logging.info('Creating Neovim config directory')
            self.config_path.mkdir(mode=0o755, parents=True)
        if not self.data_path.exists():
            logging.info('Creating Neovim data directory')
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
            raise SyncException(f'exit code {output.returncode} when running '
                                f'{self.nvim} {nvim_args} {nvim_cmds}')
        return output.stdout

    def install_packer(self):
        logging.info('Installing packer.nvim...')
        git_path = shutil.which('git')
        if not git_path:
            raise SyncException('unable to locate git binary')

        repo_url = 'https://github.com/wbthomason/packer.nvim'
        target_dir = self.packer_path / 'start' / 'packer.nvim'
        git_cmd = ('git', 'clone', '--depth', '1', repo_url, str(target_dir))
        result = subprocess.run(git_cmd, capture_output=True)
        if result.returncode != 0:
            raise SyncException('error cloning git repo')

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

    def confirm_sync(self, source_path: Path, target_path: Path) -> bool:
        print(f'{source_path} differs from {target_path}. ', end='')
        prompt = 'Overwrite? ([y]es/[n]o/view [d]iff) '
        while True:
            choice = input(prompt).lower()
            if not choice:
                continue
            if choice[0] == 'd' or choice == 'view diff':
                diff = subprocess.run(
                    ('diff', str(target_path), str(source_path),
                     '--color=always'), capture_output=True
                ).stdout
                subprocess.run(('less',), input=diff, check=True)
                continue
            match choice[0]:
                case 'y':
                    return True
                case 'n':
                    return False
                case _:
                    print(f'Invalid choice: {choice}', file=sys.stderr)

    def sync_config(self, source_dir: Path, target_dir: Path,
                    force: bool = False) -> list[Path]:
        updated_files = []
        logging.debug(f'sync_config({source_dir=}, {target_dir=}, {force=})')
        for source_path in source_dir.glob('**/*.lua'):
            if source_path.name == 'packer_compiled.lua':
                continue
            target_path = target_dir / source_path.relative_to(source_dir)
            if target_path.exists():
                if not filecmp.cmp(source_path, target_path, shallow=False):
                    if force or self.confirm_sync(source_path, target_path):
                        copyfile(source_path, target_path)
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
                copyfile(source_path, target_path)
                updated_files.append(target_path)
        return updated_files

    def push_config(self, args):
        updated_files = self.sync_config(self.repo_path, self.config_path,
                                         force=args.force)
        if any(p.name == 'plugins.lua' for p in updated_files):
            logging.info('plugins.lua updated, recompiling packer cache...')
            self.packer_compile()

    def pull_config(self, args):
        self.sync_config(self.config_path, self.repo_path, force=args.force)


def copyfile(source_path, target_path, *, follow_symlinks=True):
    logging.info(f'Copying {source_path} to {target_path}'
                 f'{" (overwriting)" if target_path.exists() else ""}...')
    shutil.copyfile(source_path, target_path, follow_symlinks=follow_symlinks)


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

    try:
        args.func(args)
    except SyncException as ex:
        print(f'Error: {ex}')
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())

"===== machine-specific options =====
" NOTE: ensure the directory path is encased in single quotes
"       rather than double quotes so it is correctly parsed
let g:nvim_cfg_dir = '~/.config/nvim/'
set shell=zsh

"===== modularized configuration files =====
exec "source ". g:nvim_cfg_dir. "global.vim"
exec "source ". g:nvim_cfg_dir. "plugins.vim"
" exec "source ". g:nvim_cfg_dir. "latex.vim"
" exec "source ". g:nvim_cfg_dir. "ocaml.vim"

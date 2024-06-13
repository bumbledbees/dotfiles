"===== vim-plug config =====
"
" Directory for vim-plug to download to
execute "call plug#begin('".g:nvim_cfg_dir."plugged')"

" Plugins for vim-plug to load
"Plug 'vim-airline/vim-airline'
Plug 'itchyny/lightline.vim'
"Plug 'feline-nvim/feline.nvim' |
"    \ Plug 'nvim-tree/nvim-web-devicons' |
Plug 'lewis6991/gitsigns.nvim'
"Plug 'airblade/vim-gitgutter'
Plug 'preservim/nerdtree' |
    \ Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-fugitive'
Plug 'dense-analysis/ale'
Plug 'Shougo/deoplete.nvim'
Plug 'neovimhaskell/haskell-vim'
Plug 'ervandew/supertab'
Plug 'preservim/vim-markdown'
Plug 'EdenEast/nightfox.nvim'

call plug#end()

lua require('gitsigns').setup()

"===== Theme =====
colorscheme duskfox
let g:lightline = {
      \ 'colorscheme': 'nightfox',
      \ }
highlight ALEInfo ctermfg=Yellow
highlight ALEWarning ctermfg=Magenta
highlight ALEError ctermfg=Red


"===== NERDTree config =====
"
" === autocommands
augroup ntree
    autocmd!
    " Start NERDTree on nvim start, move cursor into empty buffer.
    autocmd VimEnter * NERDTree | wincmd p

    " If NERDTree is the last window open, close it.
    autocmd BufEnter NERD_tree* if winnr() == winnr('$') && winnr() == 1 | quit | endif 
augroup END

" === Configuration settings
"
let NERDTreeIgnore = ['__pycache__',
                     \'dist-newstyle']
let NERDTreeMinimalUI = 1

" === NERDTree-related mappings
" [ <leader>nt ] = focus NERDTree or open a NERDTree if it's closed
nnoremap <silent> <leader>nt :call g:ConditionalNERDTreeFocus()<CR>
function! g:ConditionalNERDTreeFocus()
    try | NERDTreeFocus | catch | silent! NERDTree | endtry
endfunction

"===== vim-fugitive config =====
"
" === normal mode bindings
" <LEAD>gsp     -> horizontal split with git status
" <LEAD>gvsp    -> vertical split with git status
" <LEAD>gmrg    -> new tab for merge conflicts
" <LEAD>gdh     -> (in 3-diffsplit) keep HEAD (left pane)
" <LEAD>hdl     -> (in 3-diffsplit) accept incoming (right pane)
nnoremap <silent><leader>gsp :Gsplit :<CR>
nnoremap <silent><leader>gvsp :Gvsplit :<CR>
nnoremap <silent><leader>gmrg :tabnew<CR>:G mergetool<CR><C-w>j:setlocal splitright<CR>:Gvsplit :<CR><C-w>h
nnoremap <silent><leader>gdiff :Gvdiffsplit!<CR>
nnoremap <silent><leader>gdh :diffget //2<CR>
nnoremap <silent><leader>gdl :diffget //3<CR>

"===== lint/autocomplete/syntax plugin config =====
let g:vim_markdown_folding_disabled = 1
let g:ale_linters = {}
let g:deoplete#enable_at_startup = 1
let g:ale_sign_error = '!'
let g:ale_sign_warning = '?'
let g:ale_sign_info = 'i'
call deoplete#custom#option('sources', {
\ '_': ['ale'],
\})

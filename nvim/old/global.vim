"===== environment variables =====
" * global leader key *
let mapleader = "_"

" colors!
set termguicolors

" indentation settings
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab

" line numbering on
set nu

" enable gdb debugger integration
" packadd termdebug

" ===== bindings for terminal mode =====
" <Esc>         -> switch from terminal mode to normal mode
" <LEAD><Esc>   -> send an <Esc> signal to the terminal
" <Ctrl-w>      -> activate <C-w> window switching in terminal
" <LEAD><C-w>   -> send a <Ctrl-w> signal to the terminal
" <C-q>h        -> move one tab to the left
" <C-q>l        -> move one tab to the right
" <LEAD><C-q>   -> send a <Ctrl-q> signal to the terminal

tnoremap <Esc> <C-\><C-n>
tnoremap <leader><Esc> <Esc>
tnoremap <C-w> <C-\><C-n><C-w>
tnoremap <leader><C-w> <C-w>
tnoremap <silent><C-q>h <C-\><C-n>:tabp<CR>
tnoremap <silent><C-q>l <C-\><C-n>:tabn<CR>
tnoremap <leader><C-q> <C-q>

" ===== bindings for normal mode =====
" <LEAD>cfg     -> open new tab for editing nvim config files
" <LEAD>ktrm    -> hsplit with terminal above
" <LEAD>jtrm    -> hsplit with terminal below
" <LEAD>ltrm    -> vsplit with terminal to the right
" <LEAD>htrm    -> vsplit with terminal to the left
" <C-q>h        -> move one tab to the left
" <C-q>l        -> move one tab to the right
" <C-q>n        -> new tab
" UNBIND <C-q>
nnoremap <silent><leader>cfg :tabnew<CR>:execute 'NERDTree' g:nvim_cfg_dir<CR>
nnoremap <silent><leader>T :belowright split<CR>:terminal<CR>:exe "resize " . (&lines * 1/6)<CR>:set winfixheight<CR>
nnoremap <silent><leader>ktrm :split<CR>:terminal<CR>
nnoremap <silent><leader>jtrm :belowright split<CR>:terminal<CR>
nnoremap <silent><leader>htrm :vsplit<CR>:terminal<CR>
nnoremap <silent><leader>ltrm :botright vertical split<CR>:terminal<CR>
nnoremap <C-q> <Nop>
nnoremap <silent><C-q>h :tabp<CR>
nnoremap <silent><C-q>l :tabn<CR>
nnoremap <silent><C-q>n :tabnew<CR>

" ===== bindings for insert mode =====
" <Ctrl-q>h        -> move one tab to the left
" <Ctrl-q>l        -> move one tab to the right
" UNBIND <C-q>
inoremap <C-q> <Nop>
inoremap <silent><C-q>h <Esc>:tabp<CR>
inoremap <silent><C-q>l <Esc>:tabn<CR>
inoremap <silent><C-q>n <Esc>:tabnew<CR>

" ===== autocommands =====
augroup general
    autocmd!
    " saving a .vim file re-sources config
    autocmd BufWritePost *.vim source $MYVIMRC

    " no line numbering in terminal mode
    autocmd TermOpen * set nonu
    autocmd TermClose,BufNewFile,BufReadPost * set nu

augroup END

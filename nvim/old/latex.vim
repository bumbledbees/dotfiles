"===== tex-specific environment settings =====
let g:tex_flavor = "latex"
autocmd! FileType tex setlocal linebreak

"===== normal/visual mode latex bindings =====
augroup tex_bindings
    autocmd!
    " Move one visual line at a time in word wrap mode
    autocmd FileType tex :nnoremap <buffer> j gj
    autocmd FileType tex :vnoremap <buffer> j gj
    autocmd FileType tex :nnoremap <buffer> k gk
    autocmd FileType tex :vnoremap <buffer> k gk
    autocmd FileType tex :nnoremap <buffer> $ g$
    autocmd FileType tex :vnoremap <buffer> $ g$
    autocmd FileType tex :nnoremap <buffer> ^ g^
    autocmd FileType tex :vnoremap <buffer> ^ g^
    autocmd FileType tex :nnoremap <buffer> 0 g0
    autocmd FileType tex :vnoremap <buffer> 0 g0

    " <leader>lmk  = build pdf
    " <leader>lcln = clean working dir
    autocmd FileType tex :nnoremap <buffer> <leader>lmk :!latexmk -pdf<CR>
    autocmd FileType tex :nnoremap <buffer> <leader>lcln :!latexmk -c<CR>
augroup END 

"===== useful abbreviations =====
augroup tex_abbrevs
autocmd!

" - general new document template
autocmd FileType tex :iabbrev <buffer> __newdoc 
            \\documentclass[12pt]{article}
            \<CR>\usepackage[margin=0.75in]{geometry}
            \<CR>\usepackage{parskip}
            \<CR>
            \<CR>\author{Sam Zuk (Samuel\_Zuk@student.uml.edu)}
            \<CR>\title{}
            \<CR>
            \<CR>\begin{document}
            \<CR>    \maketitle
            \<CR>\end{document}<Esc>4k$

" - define an 'always bold' environment for text with math
autocmd FileType tex :iabbrev <buffer> __fullbold 
            \\newenvironment{fullbold}
            \<CR>    {\begingroup \bfseries \boldmath}
            \<CR>    {\endgroup}

augroup END

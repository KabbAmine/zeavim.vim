" ==========================================================
" Global plugin that allows executing Zeal from Vim.
" Version     : 2.3.0
" Creation    : 2014-04-14
" Last Change : 2018-03-12
" Maintainer  : Kabbaj Amine <amine.kabb@gmail.com>
" License     : This file is placed in the public domain.
" ==========================================================


" Vim options {{{1
if exists('g:zeavim_loaded') && (!has('unix') || !has('win32'))
    finish
endif
let g:zeavim_loaded = 1

" To avoid conflict problems.
let s:saveFileFormat = &fileformat
let s:saveCpoptions = &cpoptions
set fileformat=unix
set cpoptions&vim
" }}}

" Default mappings {{{1
if !exists('g:zv_disable_mapping')
    if !hasmapto('<Plug>Zeavim')
        nmap <unique> <Leader>z <Plug>Zeavim
    endif
    if !hasmapto('<Plug>ZVVisSelection')
        vmap <unique> <Leader>z <Plug>ZVVisSelection
    endif
    if !hasmapto('<Plug>ZVKeyDocset')
        nmap <unique> <Leader><Leader>z <Plug>ZVKeyDocset
    endif
    if !hasmapto('<Plug>ZVOperator')
        nmap <unique> gz <Plug>ZVOperator
    endif
endif

nnoremap <unique> <silent> <script> <Plug>Zeavim
            \ :call zeavim#SearchFor('', expand('<cword>'))<CR>
vnoremap <unique> <silent> <script> <Plug>ZVVisSelection
            \ :call zeavim#SearchFor('', '', 'v')<CR>
nnoremap <unique> <silent> <script> <Plug>ZVKeyDocset
            \ :call zeavim#SearchFor('!')<CR>
nnoremap <unique> <silent> <script> <Plug>ZVOperator
            \ <Esc>:setlocal operatorfunc=zeavim#OperatorFun<CR>g@
" }}}

" Commands {{{1
command! -range -bang Zeavim
            \ call zeavim#SearchFor('<bang>', expand('<cword>'), '')
command! -range ZeavimV call zeavim#SearchFor('', '', 'v')
command! -complete=customlist,zeavim#CompleteDocsets -nargs=? Docset
            \ call zeavim#DocsetInBuffer(<f-args>)
" }}}

" Keep old plugs/commands for compatibility {{{1
nmap <Plug>ZVMotion <Plug>ZVOperator
command! -range ZvV ZeavimV
command! ZVKeyDocset Zeavim!
" }}}

" Restore default vim options {{{1
let &cpoptions = s:saveCpoptions
unlet s:saveCpoptions
let &fileformat = s:saveFileFormat
unlet s:saveFileFormat
" }}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:

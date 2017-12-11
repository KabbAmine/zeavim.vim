" Global plugin that allows executing Zeal from Vim.
" Version     : 2.2.0
" Creation    : 2014-04-14
" Last Change : 2017-12-11
" Maintainer  : Kabbaj Amine <amine.kabb@gmail.com>
" License     : This file is placed in the public domain.

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

" MAPPINGS
" =====================================================================
" {{{1
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
	if !hasmapto('<Plug>ZVMotion')
		nmap <unique> gz <Plug>ZVMotion
	endif
endif

nnoremap <unique> <script> <Plug>Zeavim <SID>Zeavim
nnoremap <silent> <SID>Zeavim :call zeavim#SearchFor('', expand('<cword>'))<CR>

vnoremap <unique> <script> <Plug>ZVVisSelection <SID>ZVVisSelection
vnoremap <silent> <SID>ZVVisSelection :call zeavim#SearchFor('', '', 'v')<CR>

nnoremap <unique> <script> <Plug>ZVKeyDocset <SID>ZVKeyDocset
nnoremap <silent> <SID>ZVKeyDocset :call zeavim#SearchFor('!')<CR>

nnoremap <unique> <script> <Plug>ZVMotion <SID>ZVMotion
nnoremap <silent> <SID>ZVMotion
			\ <Esc>:setlocal operatorfunc=zeavim#OperatorFun<CR>g@
" }}}

" COMMANDS
" =====================================================================
" {{{1
" One unique command
command! -range -bang Zeavim
			\	call zeavim#SearchFor('<bang>', expand('<cword>'), visualmode())
command! -complete=customlist,zeavim#CompleteDocsets -nargs=? Docset
			\	call zeavim#DocsetInBuffer(<f-args>)

" Keep old command names for compatibility
command! -range ZvV call zeavim#SearchFor('', '', 'v')
command! ZVKeyDocset Zeavim!
" }}}

" Restore default vim options {{{1
let &cpoptions = s:saveCpoptions
unlet s:saveCpoptions
let &fileformat = s:saveFileFormat
unlet s:saveFileFormat
" }}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:

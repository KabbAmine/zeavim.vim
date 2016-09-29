" CREATION     : 2015-12-21
" MODIFICATION : 2016-09-27

" VARIABLES
" =====================================================================
" Set Zeal's executable location {{{1
if !exists('g:zv_zeal_executable')
	let g:zv_zeal_executable = has('unix') && executable('zeal') ?
				\ 'zeal' :
				\ $ProgramFiles . '\Zeal\zeal.exe'
endif
" Arguments for the executable {{{1
let g:zv_zeal_args = exists('g:zv_zeal_args') ?
			\	g:zv_zeal_args : ''
" Set Zeal's docset directory location {{{1
if !exists('g:zv_docsets_dir')
	let g:zv_docsets_dir = has('unix') ?
				\ expand('~/.local/share/Zeal/Zeal/docsets') :
				\ $LOCALAPPDATA . '\Zeal\Zeal\docsets'
endif
" A dictionary containing the docset names of some file extensions {{{1
let s:docsetsDic = {
			\	'cpp' : 'c++',
			\	'scss': 'sass',
			\	'sh'  : 'bash',
			\	'tex' : 'latex',
			\ }
" Add external docset names from a global variable {{{1
if exists('g:zv_file_types')
	" Tr spaces to _ to allow multiple docsets
	call extend(s:docsetsDic, map(g:zv_file_types, 'tr(v:val, " ", "_")'))
endif
" Order or criteria for getting the docset {{{1
let g:zv_get_docset_by = exists('g:zv_get_docset_by') ?
			\ g:zv_get_docset_by : ['file', 'ext', 'ft']
" }}}

" FUNCTIONS
" =====================================================================
function! s:Echo(typeIndex, content) abort " {{{1
	" Echo a:content with type:
	"	1- Normal.
	"	2- Warning.
	"	3- Error.

	let l:types = ['Normal', 'WarningMsg', 'ErrorMsg']
	execute 'echohl ' . (l:types[a:typeIndex - 1]) | echo a:content | echohl None
endfunction
function! s:CheckExecutable() abort " {{{1
	" Check if the Zeal's executable is present according to the global
	" variable zv_zeal_executable and return 0 if not

	if !executable(g:zv_zeal_executable)
		call s:Echo(3, 'Zeal is not present in your system or his location is not defined')
		return 0
	else
		return 1
	endif
endfunction
function! s:GetDocsetsList() abort " {{{1
	" Return a list (Strings separated by \n) of docset names.

	let s:docsetList = values(s:docsetsDic)
	if exists('g:zv_docsets_dir')
		call extend(s:docsetList, s:GetDocsetsFromDir())
	endif
	" Remove duplicates (http://stackoverflow.com/questions/6630860/remove-duplicates-from-a-list-in-vim)
	return filter(copy(s:docsetList), 'index(s:docsetList, v:val, v:key+1)==-1')
endfunction
function! s:GetDocset(file, ext, ft) abort " {{{1
	" Try to guess docset from what defined in g:zv_get_docset_by
	" By default:
	"	1. file name
	" 	2. file extension
	" 	3. file type

	let l:docset = ''
	for l:t in g:zv_get_docset_by
		for l:k in keys(s:docsetsDic)
			if match(a:{l:t}, l:k) ==# 0
				let l:docset = s:docsetsDic[l:k]
				break
			endif
			if !empty(l:docset)
				break
			endif
		endfor
	endfor

	if empty(l:docset) && !empty(a:ft)
		let l:docset = a:ft
	endif

	return l:docset
endfunction
function! s:GetDocsetsFromDir() abort " {{{1
	" Get docset names from zeal's docset directory.

	return map(glob(g:zv_docsets_dir . '/*.docset', 0, 1),
		\ 'tolower(fnamemodify(v:val, ":t:r"))')
endfunction
function! s:SetDocset() abort " {{{1
	" Return the appropriate docset name.

	let l:docset = !empty(getbufvar('%', 'manualDocset')) ?
				\	getbufvar('%', 'manualDocset') :
				\	s:GetDocset(expand('%:p:t'), expand('%:e'), &ft)
	return tolower(l:docset)
endfunction
function! s:GetVisualSelection() abort " {{{1
	" Return the visual selection from the current line.

	let l:pos = getpos("'<")
	call setpos('.', l:pos)
	return getline('.')[col("'<") - 1 : col("'>") - 1]
endfunction
function! s:FromInput() abort " {{{1
	" Ask for user input and return a list containing:
	"	* Query
	"	* Docset name (Use s:SetDocset() by default)

	let l:docset = input('Docset: ',
				\ s:SetDocset(),
				\ 'custom,zeavim#CompleteDocsets'
				\ )
	redraw!
	call s:Echo(2, 'Zeal (' . l:docset . ')')
	let l:input = input('Search for: ')

	return [l:input, l:docset]
endfunction
function! s:Zeal(docset, query) abort " {{{1
	" Execute Zeal with the docset and query passed in the arguments.

	let l:docset = !empty(a:docset) ? tr(a:docset, '_', ' ') . ':' : ''
	let l:query = !empty(a:query) ? escape(a:query, '#%') : ''
	let l:focus = has('unix') && executable('wmctrl') && v:windowid !=# 0 ?
				\ '&& wmctrl -ia ' . v:windowid . ' ' :
				\ ''
	let l:cmd = printf('!%s%s %s %s %s%s &',
				\ (has('unix') ? '' : 'start '),
				\ g:zv_zeal_executable,
				\ g:zv_zeal_args,
				\ shellescape(l:docset . l:query),
				\ l:focus,
				\ (has('unix') ? '2> /dev/null' : '')
			\ )
	silent execute l:cmd
	redraw!
endfunction
" }}}

function! zeavim#SearchFor(...) abort " {{{1
	" args: (bang, query, visual)
	" If bang
	"	Execute s:FromInput()
	" If no bang, execute Zeal with:
	"	query
	"	or visual selection if a:visal is not empty

	if !s:CheckExecutable()
		return 0
	endif

	let l:bang = exists('a:1') ? a:1 : ''
	let l:query = exists('a:2') ? a:2 : ''
	let l:visual = exists('a:3') && !empty(a:3) ? 1 : 0

	if l:bang ==# '!'
		let [l:s, l:d] = s:FromInput()
		" Allow empty docset here
		if !empty(l:s)
			call s:Zeal(l:d, l:s)
		endif
	else
		let l:s = l:visual ? s:GetVisualSelection() : l:query
		let l:d = s:SetDocset()
		if !empty(l:s) && !empty(l:d)
			call s:Zeal(l:d, l:s)
		endif
	endif
endfunction
function! zeavim#CompleteDocsets(A, L, P) abort " {{{1
	return join(sort(s:GetDocsetsList()), "\n") . "\n"
endfunction
function! zeavim#OperatorFun(...) abort " {{{1
	call zeavim#SearchFor('', getline('.')[col("'[") - 1 : col("']") - 1])
endfunction
function! zeavim#DocsetInBuffer(...) abort " {{{1
	if exists('a:000')
		let l:d = len(a:000) ># 1 ? join(a:000, ',') : join(a:000)
		call setbufvar('%', 'manualDocset', l:d)
	else
		call setbufvar('%', 'manualDocset', '')
	endif
endfunction
" 1}}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:

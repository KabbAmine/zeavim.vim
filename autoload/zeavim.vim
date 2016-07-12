" CREATION     : 2015-12-21
" MODIFICATION : 2016-05-18

" VARIABLES
" =====================================================================
" Set Zeal's executable location {{{1
if !exists('g:zv_zeal_executable')
	let g:zv_zeal_executable = has('unix') && executable('zeal') ?
				\ 'zeal' :
				\ $ProgramFiles . '\Zeal\zeal.exe'
endif
" Set Zeal's docset directory location {{{1
if !exists('g:zv_docsets_dir')
	let g:zv_docsets_dir = has('unix') ?
				\ expand('~/.local/share/Zeal/Zeal/docsets') :
				\ $LOCALAPPDATA . '\Zeal\Zeal\docsets'
endif
" A dictionary containing the docset names of some file extensions {{{1
let s:docsetsDic = {
			\ 'cpp'                   : 'c++',
			\ '^(G|g)runtfile\.'      : 'grunt',
			\ '^(G|g)ulpfile\.'       : 'gulp',
			\ '.htaccess'             : 'apache_http_server',
			\ '^(md|mdown|mkd|mkdn)$' : 'markdown',
			\ 'scss'                  : 'sass',
			\ 'sh'                    : 'bash',
			\ 'tex'                   : 'latex',
		\ }
" Add external docset names from a global variable {{{1
if exists('g:zv_file_types')
	" Tr spaces to _ to allow multiple docsets
	call extend(s:docsetsDic, map(g:zv_file_types, 'tr(v:val, " ", "_")'))
endif
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
	" Try to guess docset from:
	" 1. file name
	" 2. file extension
	" 3. file type

	for l:k in keys(s:docsetsDic)
		" If the key starts with \v then we consider it as
		" a regex, so we add magic!
		let l:pattern = l:k =~# '\v^\^' ?
					\ '\v' . l:k : l:k
		if match(a:file, l:pattern) ==# 0
			let l:docset = s:docsetsDic[l:k]
			break
		elseif match(a:ext, l:pattern) ==# 0
			let l:docset = s:docsetsDic[l:k]
			break
		elseif match(a:ft, l:pattern) ==# 0
			let l:docset = s:docsetsDic[l:k]
			break
		else
			let l:docset = ''
		endif
	endfor
	if empty(l:docset) && !empty(a:ft)
		let l:docset = a:ft
	endif
	" If still empty, then...
	if empty(l:docset)
		call s:Echo(3, 'The file type is not recognized')
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

	let l:file = expand('%:p:t')
	let l:ext = expand('%:e')
	let l:ft = &filetype
	if !empty(getbufvar('%', 'manualDocset'))
		let l:docset = getbufvar('%', 'manualDocset')
	elseif !empty(l:file) || !empty(l:ft) || !empty(l:ext)
		let l:docset = s:GetDocset(l:file, l:ext, l:ft)
	else
		call s:Echo(3, 'No file type found')
		let l:docset = ''
	endif
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

	redir => l:m
	silent call s:SetDocset()
	redir END
	" If no docset found, a message is stored into l:m
	let l:d = input('Docset: ',
				\ (!empty(l:m) ? '' : s:SetDocset()),
				\ 'custom,zeavim#CompleteDocsets'
				\ )
	redraw!
	call s:Echo(2, 'Zeal (' . l:d . ')')
	let l:input = input('Search for: ')

	return [l:input, l:d]
endfunction
function! s:Zeal(docset, query) abort " {{{1
	" Execute Zeal with the docset and query passed in the arguments.

	let l:docset = !empty(a:docset) ? tr(a:docset, '_', ' ') . ':' : ''
	let l:query = !empty(a:query) ? a:query : ''
	let l:focus = has('unix') && executable('wmctrl') && v:windowid !=# 0 ?
				\ '&& wmctrl -ia ' . v:windowid . ' ' :
				\ ''
	let l:cmd = printf('!%s%s %s %s%s &',
				\ (has('unix') ? '' : 'start '),
				\ g:zv_zeal_executable,
				\ shellescape(l:docset . fnameescape(l:query)),
				\ l:focus,
				\ (has('unix') ? '2> /dev/null' : '')
			\ )
	silent execute l:cmd
	redraw!
endfunction
" }}}

function! zeavim#SearchFor(...) abort " {{{1
	" Execute Zeal with:
	"	a:1 as a query (Or visual selection if a:2 exists)
	"	call s:FromInput() if no argument(s) were passed

	if s:CheckExecutable()
		if exists('a:1')
			let l:s = exists('a:2') ? s:GetVisualSelection() : a:1
			let l:d = s:SetDocset()
			if !empty(l:s) && !empty(l:d)
				call s:Zeal(l:d, l:s)
			endif
		else
			let [l:s, l:d] = s:FromInput()
			if !empty(l:s)
				" Allow here empty docset
				call s:Zeal(l:d, l:s)
			endif
		endif
	endif
endfunction
function! zeavim#CompleteDocsets(A, L, P) abort " {{{1
	return join(sort(s:GetDocsetsList()), "\n") . "\n"
endfunction
function! zeavim#OperatorFun(...) abort " {{{1
	call zeavim#SearchFor(getline('.')[col("'[") - 1 : col("']") - 1])
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

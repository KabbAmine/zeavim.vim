" Global plugin that allows executing Zeal from Vim.
" Version     : 1.3
" Creation    : 2014-04-14
" Last Change : 2015-03-14
" Maintainer  : Kabbaj Amine <amine.kabb@gmail.com>
" License     : This file is placed in the public domain.


" Vim options {{{1
if exists("g:zeavim_loaded")
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
" <Plug> names.
let s:zeavimPlugs = ['Zeavim', 'ZVKeyword' , 'ZVKeyDocset']

if !exists('g:zv_disable_mapping')

	" Default mappings.
	let s:zeavimKeys  = ['<Leader>z' , '<Leader>Z' , '<Leader><Leader>z']

	for s:n in range(0, len(s:zeavimPlugs) - 1)
		if !hasmapto(s:zeavimPlugs[s:n])
			exec "nmap <unique> ".s:zeavimKeys[s:n]." <Plug>".s:zeavimPlugs[s:n]
		endif
	endfor
	exec "vmap <unique> ".s:zeavimKeys[0]." <Plug>ZVVisSelection"

endif

" Map the <Plug>s with the appropriate <SID>s.
if hasmapto('<Plug>Zeavim')
	nnoremap <unique> <script> <Plug>Zeavim <SID>Zeavim
	nnoremap <silent> <SID>Zeavim  :call <SID>Zeavim("<cword>")<CR>
endif
for s:p in s:zeavimPlugs[1:]
	let s:plug = "<Plug>".s:p
	if hasmapto(s:plug)
		exec "nnoremap <unique> <script> <Plug>".s:p." <SID>".s:p
		exec "nnoremap <silent> <SID>".s:p." :call <SID>".s:p."()<CR>"
	endif
endfor
if hasmapto('<Plug>ZVVisSelection')
	vnoremap <unique> <script> <Plug>ZVVisSelection <SID>ZVVisSelection
	vnoremap <silent> <SID>ZVVisSelection  :call <SID>ZVVisSelection()<CR>
endif
" }}}

" COMMANDS
" =====================================================================

" {{{1
command! Zeavim call s:Zeavim("<cword>")
command! ZvK call s:ZVKeyword()
command! ZvKD call s:ZVKeyDocset()
command! -range ZvV call s:ZVVisSelection()
command! -complete=custom,CompleteDocsetName -nargs=? Docset :let b:manualDocset = '<args>'
" }}}

" VARIABLES
" =====================================================================

" Set Zeal's Location {{{1
	if !exists('g:zv_zeal_directory')
		if has('win32') || has('win64')
			let g:zv_zeal_directory = $ProgramFiles."/Zeal/zeal.exe"
		else
			let g:zv_zeal_directory = "/usr/bin/zeal"
		endif
	endif
" Set Zeal's execution command {{{1
	if has('win32') || has('win64')
		let s:zealExecCmd = "!start \"".g:zv_zeal_directory."\""
	else
		let s:zealExecCmd = "! ".g:zv_zeal_directory.""
	endif
" A dictionary who contains the docset names of some file extensions {{{1
	let s:zeavimDocsetNames = {
				\ 'cpp': 'C++',
				\ 'js': 'Javascript',
				\ 'md': 'Markdown',
				\ 'mdown': 'Markdown',
				\ 'mkd': 'Markdown',
				\ 'mkdn': 'Markdown',
				\ 'py': 'Python',
				\ 'scss': 'Sass',
				\ 'sh': 'Bash',
				\ 'tex': 'Latex',
				\ }
" Add external docset names from a global variable {{{1
	if exists("g:zv_added_files_type")
		call extend(s:zeavimDocsetNames, g:zv_added_files_type)
	endif
" }}}

" FUNCTIONS
" =====================================================================

" General functions
" ************************
function s:ShowMessage(messageTypeNumber, messageContent) " {{{1
	" Show a message according to his highlighting type.
	"	1- White (Normal).
	"	2- Red (Warning).
	"	3- Background in red (Error).
	"	4- Blue (Directory).

	if (a:messageTypeNumber == 1)
		let s:messageType = "Normal"
	elseif (a:messageTypeNumber == 2)
		let s:messageType = "WarningMsg"
	elseif (a:messageTypeNumber == 3)
		let s:messageType = "ErrorMsg"
	elseif (a:messageTypeNumber == 4)
		let s:messageType = "Directory"
	endif

	execute "echohl ".s:messageType
	echo a:messageContent
	echohl None

endfunction
function s:Make1stLetterUpperCase(string) " {{{1
	" Make the 1st letter of a string in uppercase.

	if !empty(a:string)
		let s:stringUpper = toupper(strpart(a:string, 0, 1)).tolower(strpart(a:string, 1))
		return s:stringUpper
	endif

endfunction
function s:GetVisualSelection() " {{{1
	" Return the visual selection.

	let s:selection=getline("'<")
	let s:cursorPos=getpos("'<'")
	let [line1,col1] = getpos("'<")[1:2]
	let [line2,col2] = getpos("'>")[1:2]
	call setpos('.', s:cursorPos)
	return s:selection[col1 - 1: col2 - 1]

endfunction
function CompleteDocsetName(A, L, P) " {{{1
	" Return a list (Strings separated by \n) of docset names.

	let s:docsetList = values(s:zeavimDocsetNames)
	if exists("g:zv_docsets_dir")
		call extend(s:docsetList, s:GetDocsetNameFromDir(g:zv_docsets_dir))
	endif
	if exists("g:zv_lazy_docset_list")
		call extend(s:docsetList, g:zv_lazy_docset_list)
	endif
	" Remove duplicates (http://stackoverflow.com/questions/6630860/remove-duplicates-from-a-list-in-vim)
	let s:docsetListClean = filter(copy(s:docsetList), 'index(s:docsetList, v:val, v:key+1)==-1')
	return join(sort(s:docsetListClean), "\n")."\n"

endfunction
" }}}

" Processing functions
" ************************
function s:CheckZeal() " {{{1
	" Check if the Zeal's executable is present according to the global
	" variable zv_zeal_directory and return 0 if not

	if !executable(g:zv_zeal_directory)
		call s:ShowMessage(4, "Zeal is not present in your system or his location is not defined")
		return 0
	else
		return 1
	endif

endfunction
function s:GetDocsetNameFromList(fileExtension, fileType) " {{{1
	" Get and return the doscset name if the extension file is present
	" on the variable 'zeavimDocsetNames'.

	if has_key(s:zeavimDocsetNames, a:fileType)
		let s:docsetName = s:zeavimDocsetNames[a:fileType]
	elseif has_key(s:zeavimDocsetNames, a:fileExtension)
		let s:docsetName = s:zeavimDocsetNames[a:fileExtension]
	elseif (a:fileType != '')
		let s:docsetName = a:fileType
	else
		call s:ShowMessage(2, "The file type is not recognized")
	endif
	return s:docsetName

endfunction
function s:GetDocsetNameFromDir(directory) " {{{1
	" Get docset names from zeal docset directory.

	let l:docsetList = glob(a:directory . '*.docset', 0, 1)
	for l:index in range(0, len(l:docsetList) - 1)
		let l:docsetList[l:index] = substitute(l:docsetList[l:index], '^.*\(/\|\\\)\([A-Za-z0-9_]\+\)\.docset$', '\2', 'g')
		let l:docsetList[l:index] = substitute(l:docsetList[l:index], '_', ' ', 'g')
		let l:docsetList[l:index] = s:Make1stLetterUpperCase(l:docsetList[l:index])
	endfor
	return l:docsetList

endfunction
function s:GetDocsetName() " {{{1
	"  Get and return the appropriate docset name.

	let s:fileExtension = expand("%:e")
	let s:fileType = &filetype

	if exists('b:manualDocset') && !empty(b:manualDocset)
		let s:docsetName = b:manualDocset
	elseif (s:fileType != '') || (s:fileExtension != '')
		let s:docsetName = s:GetDocsetNameFromList(s:fileExtension, s:fileType)
	else
		call s:ShowMessage(2, "No file type found")
		let s:docsetName = ""
	endif

	let s:docsetName = s:Make1stLetterUpperCase(s:docsetName)
	return s:docsetName

endfunction
function s:ExecuteZeal(docsetName, selection) " {{{1
	" Execute Zeal with the docset and selection passed in the arguments.

	if (a:docsetName != "")
		let s:executeZeal = "silent :".s:zealExecCmd." --query \"".a:docsetName.":".a:selection."\""
	elseif (a:selection != "")
		let s:executeZeal = "silent :".s:zealExecCmd." --query \"".a:selection."\""
	else
		let s:executeZeal = "silent :".s:zealExecCmd.""
	endif

	if has ('win32') || has('win64')
		execute s:executeZeal. " > NUL"
	else
		execute s:executeZeal." 2> /dev/null &"
	endif
	redraw!

endfunction
" }}}

" Main functions.
" ************************
function s:Zeavim(selection) " {{{1
	" Call Zeal normally with the argument 'selection' as a keyword.

	if s:CheckZeal() == 1
		let s:docsetName = s:GetDocsetName()
		let s:selection = expand(a:selection)

		if (s:selection != "") && (s:docsetName != "")
			call s:ExecuteZeal(s:docsetName, s:selection)
		endif
	endif

endfunction
function s:ZVKeyword() " {{{1
	" Give a keyword as an input from Vim and call Zeal.

	if s:CheckZeal() == 1
		let s:docsetName = s:GetDocsetName()
		if (s:docsetName != '')
			call s:ShowMessage(4, "Zeal (".s:docsetName.")")
			let s:keywordInput = input("Search for: ")
			if (s:keywordInput != '')
				call s:ExecuteZeal(s:docsetName, s:keywordInput)
			else
				normal <C-l>
				call s:ShowMessage(1, "No action is done")
			endif
		endif
	endif

endfunction
function s:ZVKeyDocset() " {{{1
	" Give the keyword and the docset manually.

	if s:CheckZeal() == 1
		let s:docsetName = input("Docset: ", "", "custom,CompleteDocsetName")
		redraw!
		call s:ShowMessage(4, "Zeal (".s:docsetName.")")
		let s:keywordInput = input("Search for: ")

		if (s:docsetName == '') && (s:keywordInput == '')
			normal <C-l>
			call s:ShowMessage(1, "No action is done")
		else
			call s:ExecuteZeal(s:docsetName, s:keywordInput)
		endif
	endif

endfunction
function s:ZVVisSelection() " {{{1
	" Call Zeal with the current visual selection.

	if s:CheckZeal() == 1
		let s:docsetName = s:GetDocsetName()
		let s:selection = s:GetVisualSelection()

		if (s:selection != "") && (s:docsetName != "")
			call s:ExecuteZeal(s:docsetName, s:selection)
		endif
	endif

endfunction
" }}}


" Restore default vim options {{{1
let &cpoptions = s:saveCpoptions
unlet s:saveCpoptions
let &fileformat = s:saveFileFormat
" }}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:

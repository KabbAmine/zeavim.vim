" Global plugin that allows executing Zeal from Vim.
" Creation	  : 2014-04-14
" Last Change : 2014-08-23
" Maintainer  : Kabbaj Amine <amine.kabb@gmail.com>
" License	  : This file is placed in the public domain.

" TODO


if exists("g:zeavim")
	finish
endif
let g:zeavim = 1

" To avoid conflict problems.
let s:save_file_format = &fileformat
let s:save_cpoptions = &cpoptions
set fileformat=unix
set cpoptions&vim


" MAPPINGS
" =====================================================================

if !exists('g:ZV_disable_mapping')
	" Call Zeal normally {
	if !hasmapto('<Plug>ZVCall')
		nmap <unique> <Leader>z  <Plug>ZVCall
	endif
	nnoremap <unique> <script> <Plug>ZVCall <SID>ZV
	nnoremap <silent> <SID>ZV  :call <SID>CallZealNormally("<cword>")<CR>
	" }
	" Call Zeal with keyword as an input {
	if !hasmapto('<Plug>ZVKeyCall')
		nmap  <unique> <Leader>Z  <Plug>ZVKeyCall
	endif
	nnoremap <unique> <script> <Plug>ZVKeyCall <SID>ZVKey
	nnoremap <silent> <SID>ZVKey  :call <SID>CallZealWithKeyword()<CR>
	" }
	" Call Zeal with docset and keyword as an inputs {
	if !hasmapto('<Plug>ZVKeyDoc')
		nmap <unique> <Leader><leader>z  <Plug>ZVKeyDoc
	endif
	nnoremap <unique> <script> <Plug>ZVKeyDoc <SID>ZVKeyDoc
	nnoremap <silent> <SID>ZVKeyDoc  :call <SID>CallZealWithKeywordAndDocset()<CR>
	" }
	" Call Zeal with the current visual selection {
	if !hasmapto('<Plug>ZVVisualSelecCall')
		vmap <unique> <Leader>z  <Plug>ZVVisualSelecCall
	endif
	vnoremap <unique> <script> <Plug>ZVVisualSelecCall <SID>ZVVIsualSelec
	vnoremap <silent> <SID>ZVVIsualSelec  :call <SID>CallZealWithSelection()<CR>
	" }
endif


" VARIABLES
" =====================================================================

" Global variables
" ************************
" Set Zeal's Location {
	if !exists('g:ZV_zeal_directory')
		if has('win32') || has('win64')
			let g:ZV_zeal_directory = $ProgramFiles."/Zeal/zeal.exe"
		else
			let g:ZV_zeal_directory = "/usr/bin/zeal"
		endif
	endif
" }

" Local variables
" ************************
" Set Zeal's execution command {
	if has('win32') || has('win64')
		let s:zeavimExecutionCommand = "!start \"".g:ZV_zeal_directory."\""
	else
		let s:zeavimExecutionCommand = "! ".g:ZV_zeal_directory.""
	endif
" }
" A dictionary who contains the docset names of some file extensions {
	let s:zeavimDocsetNames = {
				\ 'c': 'C',
				\ 'cpp': 'C++',
				\ 'css': 'Css',
				\ 'html': 'Html',
				\ 'java': 'Java',
				\ 'js': 'Javascript',
				\ 'markdown': 'Markdown',
				\ 'md': 'Markdown',
				\ 'mdown': 'Markdown',
				\ 'mkd': 'Markdown',
				\ 'mkdn': 'Markdown',
				\ 'php': 'Php',
				\ 'py': 'Python',
				\ 'scss': 'sass',
				\ 'sh': 'Bash',
				\ 'tex': 'Latex',
				\ }
" }
" GLOBAL VARIABLE - Add the external docset names from a global variable {
	if exists("g:ZV_added_files_type")
		call extend(s:zeavimDocsetNames, g:ZV_added_files_type, "error")
	else
		let g:ZV_added_files_type = {}
	endif
" }


" FUNCTIONS
" =====================================================================

" General functions
" ************************
function s:ShowMessage(messageTypeNumber, messageContent)
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
function s:Make1stLetterUpperCase(string)
	" Make the 1st letter of a string in uppercase.

	if !empty(a:string)
		let s:stringUpper = toupper(strpart(a:string, 0, 1)).tolower(strpart(a:string, 1))
		return s:stringUpper
	endif

endfunction
function s:GetVisualSelection()
	" Return the visual selection.

	let s:selection=getline("'<")
	let s:cursorPos=getpos("'<'")
	let [line1,col1] = getpos("'<")[1:2]
	let [line2,col2] = getpos("'>")[1:2]
	call setpos('.', s:cursorPos)
	return s:selection[col1 - 1: col2 - 1]

endfunction

" Processing functions
" ************************
function s:CheckZeal()
	" Check if the Zeal's executable is present according to the global
	" variable ZV_zeal_directory and return 0 if not

	if !executable(g:ZV_zeal_directory)
		call s:ShowMessage(4, "Zeal is not present in your system or his location is not defined")
		" sleep 1
		" execute "normal \<C-l>"
		return 0
	else
		return 1
	endif

endfunction
function s:GetDocsetNameFromTheList(fileExtension, fileType)
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
function s:GetDocsetName()
	"  Get and return the appropriate docset name.

	let s:fileExtension = expand("%:e")
	let s:fileType = &filetype

	if (s:fileType != '') || (s:fileExtension != '')
		let s:docsetName = s:GetDocsetNameFromTheList(s:fileExtension, s:fileType)
	else
		call s:ShowMessage(2, "No file type found")
		let s:docsetName = ""
	endif

	let s:docsetName = s:Make1stLetterUpperCase(s:docsetName)
	return s:docsetName

endfunction
function s:ExecuteZeal(docsetName, selection)
	" Execute Zeal with the docset and selection passed in the arguments.

	if (a:docsetName != "")
		let s:executeZeal = "silent :".s:zeavimExecutionCommand." --query '".s:docsetName.":".a:selection."'"
	elseif (a:selection != "")
		let s:executeZeal = "silent :".s:zeavimExecutionCommand." --query '".a:selection."'"
	else
		let s:executeZeal = "silent :".s:zeavimExecutionCommand.""
	endif

	if has ('win32') || has('win64')
		execute s:executeZeal
	else
		execute s:executeZeal." & 2> /dev/null"
	endif
	redraw!

endfunction

" Main functions.
" ************************
function s:CallZealNormally(selection)
	" Call Zeal normally with the argument 'selection' as a keyword.

	if s:CheckZeal() == 1
		let s:docsetName = s:GetDocsetName()
		let s:selection = expand(a:selection)

		if (s:selection != "") && (s:docsetName != "")
			call s:ExecuteZeal(s:docsetName, s:selection)
		endif
	endif

endfunction
function s:CallZealWithKeyword()
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
function s:CallZealWithKeywordAndDocset()
	" Give the keyword and the docset manually.

	if s:CheckZeal() == 1
		let s:docsetName = input("Docset: ")
		let s:keywordInput = input("Search for: ")

		if (s:docsetName == '') && (s:keywordInput == '')
			normal <C-l>
			call s:ShowMessage(1, "No action is done")
		else
			call s:ExecuteZeal(s:docsetName, s:keywordInput)
		endif
	endif

endfunction
function s:CallZealWithSelection()
	" Call Zeal with the current visual selection.

	if s:CheckZeal() == 1
		let s:docsetName = s:GetDocsetName()
		let s:selection = s:GetVisualSelection()

		if (s:selection != "") && (s:docsetName != "")
			call s:ExecuteZeal(s:docsetName, s:selection)
		endif
	endif

endfunction

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
let &fileformat = s:save_file_format

" ==========================================================
" Creation     : 2015-12-21
" Last change  : 2017-12-11
" ==========================================================


" ==========================================================
" 			VARIABLES
" ==========================================================

" Zeal's executable location {{{1
if !exists('g:zv_zeal_executable')
    let g:zv_zeal_executable = has('unix') && executable('zeal')
                \ ? 'zeal'
                \ : $ProgramFiles . '\Zeal\zeal.exe'
endif
" 1}}}

" Arguments for the executable {{{1
let g:zv_zeal_args = get(g:, 'zv_zeal_args', '')
" 1}}}

" Keep or not the focus (Need wmctrl and works only on GNU/linux) {{{1
let g:zv_keep_focus = get(g:, 'zv_keep_focus', 1)
" 1}}}

" Set Zeal's docset directory location {{{1
if !exists('g:zv_docsets_dir')
    let g:zv_docsets_dir = has('unix')
                \ ? $HOME . '/.local/share/Zeal/Zeal/docsets'
                \ : $LOCALAPPDATA . '\Zeal\Zeal\docsets'
endif
" 1}}}

" File type docsets {{{1
let s:docsetsDic = {
            \   'scss': 'sass',
            \   'sh'  : 'bash',
            \   'tex' : 'latex'
            \ }
if exists('g:zv_file_types')
    call extend(s:docsetsDic, g:zv_file_types)
endif
" 1}}}

" Order or criteria for getting the docset {{{1
let g:zv_get_docset_by = get(g:, 'zv_get_docset_by', ['file', 'ext', 'ft'])
" 1}}}

" Docset keywords {{{1
let s:docset_keywords = {
            \   'apache_http_server'   : 'apache',
            \   'appcelerator_titanium': 'titanium',
            \   'aws_javascript'       : 'awsjs',
            \   'cocos2d-x'            : 'cocos2dx',
            \   'common_lisp'          : 'lisp',
            \   'emacs_lisp'           : 'elisp',
            \   'font_awesome'         : 'awesome',
            \   'jquery_mobile'        : 'jquerym',
            \   'jquery_ui'            : 'jqueryui',
            \   'lo-dash'              : 'lodash',
            \   'net_framework'        : 'net',
            \   'play_java'            : 'playjava',
            \   'play_scala'           : 'playscala',
            \   'polymer.dart'         : 'polymerdart',
            \   'python_2'             : 'python2',
            \   'python_3'             : 'python3',
            \   'qt_4'                 : 'qt4',
            \   'ruby_on_rails_3'      : 'ror3',
            \   'ruby_on_rails_4'      : 'ror4',
            \   'ruby_on_rails_5'      : 'ror5',
            \   'semantic_ui'          : 'semantic',
            \   'sencha_touch'         : 'sencha',
            \   'spring_framework'     : 'spring',
            \   'unity_3d'             : 'unity3d',
            \   'vmware_vsphere'       : 'vsphere'
            \ }
" }}}

" ==========================================================
" 			FUNCTIONS
" ==========================================================

function! s:Echo(typeIndex, content) abort " {{{1
    " Echo a:content with type 1:Normal, 2:Warning, 3:Error

    let l:types = ['Normal', 'WarningMsg', 'ErrorMsg']
    execute 'echohl ' . (l:types[a:typeIndex - 1])
    echo a:content | echohl None
endfunction
" 1}}}

function! s:CheckExecutable() abort " {{{1
    " Check if the Zeal's executable is present according to the global
    " variable zv_zeal_executable and return 0 if not

    if !executable(g:zv_zeal_executable)
        call s:Echo(3, 'Zeal is not present in your system or ' .
                    \ 'his location is not defined')
        return 0
    else
        return 1
    endif
endfunction
" 1}}}

function! s:GetDocsetsList() abort " {{{1
    " Return a list (Strings separated by \n) of docset names.

    let l:docsList = values(s:docsetsDic)
    if exists('g:zv_docsets_dir')
        call extend(l:docsList, s:GetDocsetsFromDir())
    endif
    let l:docs = []
    for l:d in l:docsList
        " Split multiple docsets keys (e.g. javascript,node)
        if !empty(matchstr(l:d, ','))
            let l:docs += split(l:d, ',')
        else
            call add(l:docs, l:d)
        endif
    endfor
    " Remove duplicates (http://stackoverflow.com/questions/6630860/remove-duplicates-from-a-list-in-vim)
    return filter(l:docs, 'index(l:docs, v:val, v:key+1)==-1')
endfunction
" 1}}}

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
" 1}}}

function! s:GetDocsetsFromDir() abort " {{{1
    " Get docset names from zeal's docset directory.

    return map(glob(g:zv_docsets_dir . '/*.docset', 0, 1),
                \ 'tolower(fnamemodify(v:val, ":t:r"))')
endfunction
" 1}}}

function! s:SetDocset() abort " {{{1
    " Return the appropriate docset name.

    let l:docset = !empty(getbufvar('%', 'manualDocset'))
                \ ? getbufvar('%', 'manualDocset')
                \ :s:GetDocset(expand('%:p:t'), expand('%:e:e'), &ft)
    return tolower(l:docset)
endfunction
" 1}}}

function! s:GetVisualSelection() abort " {{{1
    " Return the visual selection from the current line.

    let l:pos = getpos("'<")
    call setpos('.', l:pos)
    return getline('.')[col("'<") - 1 : col("'>") - 1]
endfunction
" 1}}}

function! s:FromInput() abort " {{{1
    " Ask for user input and return a list containing:
    "	* Query
    "	* Docset name (Use s:SetDocset() by default)

    let l:docset = input('Docset: ',
                \ s:SetDocset(),
                \ 'customlist,zeavim#CompleteDocsets'
                \ )
    redraw!
    call s:Echo(2, 'Zeal (' . l:docset . ')')
    let l:input = input('Search for: ')
    return [l:input, l:docset]
endfunction
" 1}}}

function! s:Zeal(docset, query) abort " {{{1
    " Execute Zeal with the docset(s) and query passed in the arguments.
    " a:docset can contain multiple docsets e.g: 'docs1,docs2'

    let l:docset = ''
    for l:d in map(split(a:docset, ','), 'tr(v:val, " ", "_")')
        let l:docset .= get(s:docset_keywords, l:d, l:d) . ','
    endfor
    let l:docset = !empty(l:docset) ? l:docset[0:-2] . ':' : ''
    let l:query = !empty(a:query) ? escape(a:query, '#%') : ''
    let l:focus = g:zv_keep_focus && has('unix') &&
                \	executable('wmctrl') && v:windowid !=# 0 ?
                \		'&& wmctrl -ia ' . v:windowid . ' ' : ''
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
" 1}}}

function! zeavim#SearchFor(...) abort " {{{1
    " args: (bang, query, visual)
    " If bang
    "	Execute s:FromInput()
    " If no bang, execute Zeal with:
    "	query
    "	or visual selection if a:visual is not empty

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
" 1}}}

function! zeavim#CompleteDocsets(a, c, p) abort " {{{1
    let l:docs = sort(s:GetDocsetsList())
    if a:a =~# ',$'
        " e.g 'docset1,'
        let l:candidates = map(copy(l:docs), 'a:a . v:val')
    elseif a:a =~# ',\S*'
        " e.g 'docset1,do'
        let l:doc_start = split(a:a, ',')[-1]
        let l:docs = filter(l:docs, 'v:val =~ "^" . l:doc_start')
        let l:candidates = map(l:docs, 'a:a . v:val[len(l:doc_start):]')
    else
        let l:candidates = l:docs
    endif
    return filter(l:candidates, 'v:val =~ a:a')
endfunction
" 1}}}

function! zeavim#OperatorFun(...) abort " {{{1
    call zeavim#SearchFor('', getline('.')[col("'[") - 1 : col("']") - 1])
endfunction
" 1}}}

function! zeavim#DocsetInBuffer(...) abort " {{{1
    let l:d = exists('a:1') ? join(split(a:1), ',') : ''
    call setbufvar('%', 'manualDocset', l:d)
endfunction
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:

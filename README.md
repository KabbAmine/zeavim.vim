Zeavim, <small>Zeal for Vim</small>
===================================

![Badge version](https://img.shields.io/badge/version-2.3.1-blue.svg?style=flat-square "Badge for version")
![License version](https://img.shields.io/badge/license-public-blue.svg?style=flat-square "Badge for license")

[Description](#description) | [Installation](#description) | [Usage](#usage) | [Mapping](#mapping) | [Commands](#commands) | [Settings](#settings) | [Notes](#notes)

Description <a id="description"></a>
------------------------------------

Zeavim allows to use the offline documentation browser [Zeal](http://zealdocs.org) from Vim.

![Zeavim in use](.img/zeavim.gif "Zeavim common usage")

### Features

- Search for word under cursor, visual selection or the result of a motion/text-object.
- Search without losing focus in GNU/Linux.
- Narrow search with a docset or a query.
- Allow using multiple docsets.
- Docset names completion.
- Define you own docsets using patterns.
- Work on GNU/Linux and Windows.

Installation <a id="installation"></a>
--------------------------------------

To use zeavim, you need of course to have Zeal installed. Grab it from [here](http://zealdocs.org/download.html) and install it .

### Manual installation

Install the distributed files into Vim runtime directory which is usually `~/.vim/`, or `$HOME/vimfiles` on Windows.

### Using a plugin manager

With [Vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'KabbAmine/zeavim.vim'
```

Usage <a id="usage"></a>
------------------------

There are 3 ways of using zeavim:

1. `<leader>z` or `:Zeavim\ZeavimV`

	Search for the word under cursor or the current visual selection with the docset defined automatically<sup>[+](#plus)</sup>.

2. `gz{motion/text-object}`

	Act like an operator and search for the result of a motion/text-object with the docset defined automatically<sup>[+](#plus)</sup> (*e.g. `gziW` will search for the inner Word*).

3. `<leader><leader>z` or `:Zeavim!`

	Narrow search with a docset<sup>+</sup> and a query (A default docset is provided).
	
	![LeaderLeader-z example](.img/leaderLeaderZ.gif "An example of how to use leader-leader-z with zeavim")
	
	- Multiple docsets can be defined, just separate them by a comma.
	- Docset name(s) can be completed using `tab`.

**<sup><a id="plus">+</a></sup>** The current file type by default.

Mapping <a id="mapping"></a>
----------------------------

Use the following to change the mappings:

```vim
nmap <leader>z <Plug>Zeavim
vmap <leader>z <Plug>ZVVisSelection
nmap gz <Plug>ZVOperator
nmap <leader><leader>z <Plug>ZVKeyDocset
```

**N.B:** The old `<Plug>ZVMotion` is still available to maintain compatibility.

Commands <a id="commands"></a>
------------------------------

### Main commands

```vim
:Zeavim     " NORMAL mode (The same as <Plug>Zeavim)
:ZeavimV    " VISUAL mode (The same as <Plug>ZVVisSelection)
:Zeavim!    " Ask for docset and query (The same as <Plug>ZVKeyDocset)
```

**N.B:** The commands `ZvV` and `ZVKeyDocset` are still available to maintain compatibility with older versions of the plugin.

### Specify manually a docset

```vim
:Docset DOCSET1,DOCSET2
```

If you need a lazy way to specify a docset(s), you can use the command above.  
As an example, I'm working on a `scss` file but I want to get `compass` documentation when using Zeavim, so I just need to specify manually this docset:

```vim
Docset compass
```

Then Zeavim **only for the current buffer** will use `compass` as a docset.  
To set back the initial docset, a simple `Docset` without argument is enough.

![Specify manually a docset](.img/docsetCmd.gif)

- Note that you can define multiple docsets here, separated by comma(s).
- The docset name(s) can be completed.

Settings <a id="settings"></a>
------------------------------

Please refer to the [doc file](./doc/zeavim.txt) for a full description of the options.

----------

* `g:zv_zeal_executable` - Define location of zeal's executable.

  default:  
  ```vim
  let g:zv_zeal_executable = has('win32')
              \ ? $ProgramFiles . '\Zeal\zeal.exe'
              \ : 'zeal'
  ```

----------

* `g:zv_file_type` - Map specific regex patterns (file names, file types or file extensions) to docset(s).

  default:
  ```vim
  let g:zv_file_types = {
              \   'scss': 'sass',
              \   'sh'  : 'bash',
              \   'tex' : 'latex'
              \ }
  ```

  e.g:
  ```vim
  let g:zv_file_types = {
                  \    'css'                      : 'css,foundation',
                  \    '.htaccess'                : 'apache_http_server',
                  \    '\v^(G|g)runt\.'           : 'gulp,javascript,nodejs',
                  \    '\v^(G|g)ulpfile\.'        : 'grunt',
                  \    '\v^(md|mdown|mkd|mkdn)$'  : 'markdown',
                  \ }
  ```

----------

* `g:zv_disable_mapping` - Disable default mappings.

  default: `0`

----------

*  `g:zv_get_docset_by` - Set in which order and which criteria should be used when trying to match a pattern in `g:zv_file_types`.

  default: `['file', 'ext', 'ft']`.

  e.g:
  ```vim
  " Find matching pattern to the file type only:
  let g:zv_get_docset_by = ['ft']

  " Find matching pattern to the extension first, then to the file name 
  " and finally to the type.
  let g:zv_get_docset_by = ['ext', 'file', 'ft']
  ```

  to guess docset is by pattern matching, the item & its order is a matter.

----------

* `g:zv_docsets_dir` - Directory where are stored zeal's docsets for command completion purpose.

  default:
  ```vim
  let g:zv_docsets_dir = has('win32')
	\ ? $LOCALAPPDATA . '\Zeal\Zeal\docsets'
	\ : $HOME . '/.local/share/Zeal/Zeal/docsets'
  ```

----------

* `g:zv_keep_focus` - Keep or not the focus on vim after executing zeal (Need `wmtcrl` to be installed and works only on GNU/Linux).

  default: `1`

My configuration
----------------

```vim
nmap gzz <Plug>Zeavim
vmap gzz <Plug>ZVVisSelection
nmap <leader>z <Plug>ZVKeyDocset
nmap gZ <Plug>ZVKeyDocset<CR>
nmap gz <Plug>ZVOperator
let g:zv_keep_focus = 0
let g:zv_file_types = {
            \   'help'                : 'vim',
            \   'javascript'          : 'javascript,nodejs',
            \   'python'              : 'python_3',
            \   '\v^(G|g)ulpfile\.js' : 'gulp,javascript,nodejs',
            \ }
let g:zv_zeal_args = g:has_unix ? '--style=gtk+' : ''
```

Notes <a id="notes"></a>
------------------------

Zeavim was my first vim plugin and it was created in the beginning for a personal use, so please feel free to report issues and submit PR.

Thanks to [Jerzy Kozera](https://github.com/jkozera) for creating such wonderful open-source application.

Thanks to Bram Moolenaar for creating the best piece of software in the world :heart:

Thanks to you if you're using zeavim.

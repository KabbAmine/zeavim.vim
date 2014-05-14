Zeavim - Zeal for Vim
=====================

Description
-------------

Zeavim allows to use [Zeal](http://zealdocs.org) documentation browser directly from [Vim](http://vim.org).

This plugin was tested in GNU/Linux and Windows.

You can find this README in [french](.various/README-fr.md).


Installation
-------------

To use zeavim, you need of course to have Zeal installed. Grab it from [here](http://zealdocs.org/download.html) and install it .

### Manual installation

Install the distributed files into Vim runtime directory which is usually `~/.vim/`, or `$HOME/vimfiles` on Windows.

### Using Pathogen
If you're using pathogen, extract the file into `bundle` directory.

### Using Vundle
Just add the following line in the Vundle part of your vimrc

	Plugin 'KabbAmine/zeavim.vim'

Then proceed to the installation of the plugin with the following command:

	:PluginInstall


Usage
-----

They are 3 ways of using zeavim:

1.	`<leader>z` - To execute Zeal with the current word as a keyword and the file type (Or file extension some times) as a docset.
2.	`<leader>Z` (Note the capital z) - To use the file type as a docset and specify the keyword manually.

	![Zeavim using &lt;leader&gt;Z](.various/img/leader-Z.jpg)

3.	`<leader><leader>z` - To specify manually both keyword and docset.

	![Zeavim using &lt;leader&gt;&lt;leader&gt;z](.various/img/leader-leader-z.jpg)


Mapping
-------

You can easily change the mapping keys of zeavim:

-	For `<leader>z`

		nmap NEW_MAPPING <Plug>ZVCall

-	For `<leader>Z`

		nmap NEW_MAPPING <Plug>ZVKeyCall

-	For `<leader><leader>z`

		nmap NEW_MAPPING <Plug>ZVKeyDoc

Or you can in a global way change the leader key in Vim (Is / by default) by putting in your vimrc:

	let mapleader="NEW_LEADER_KEY"


Customization
-------------

### Location of Zeal

By default zeavim assume that *zeal* is located in `%ProgramFiles/Zeal/zeal.exe` for Windows and `/usr/bin/zeal` for UNIX systems.
You can specify Zeal's location manually by adding in your vimrc:

	if has('win32') || has('win64')
		let g:ZV_zeal_directory = " path\\to\\zeal.exe\""
	else
		let g:ZV_zeal_directory = "/usr/bin/zeal"
	endif

### Adding file types

Zeavim generates the zeal docset name from the extension (Or the filetype vim option) of the current file, but if you need to add some other file types, you can create in your vimrc a dictionnary with the extension or the vim file type as the key and the value as the docset name:

	let g:ZV_added_files_type = {
				\ 'EXTENSION': 'DOCSET_NAME',
				\ 'EXTENSION2': 'DOCSET_NAME2',
				\ }

As an example (Those file types are already included into zeavim):

	let g:ZV_added_files_type = {
				\ 'cpp': 'C++',
				\ 'js': 'Javascript',
				\ 'md': 'Markdown',
				\ 'mdown': 'Markdown',
				\ 'mkd': 'Markdown',
				\ 'scss': 'Sass',
				\ }


Notes
-----

Zeavim is my first vim plugin and it was created in the beginning for a personal use, so please feel free to report bug(s) and contact me if you want, I usually answer in 1-2 days.

Thank to [Jerzy Kozera](https://github.com/jkozera) for creating such wonderful open-source application.

Thank to Bram Moolenaar for creating the best piece of software in the world :D

Thank to you if you're using zeavim.

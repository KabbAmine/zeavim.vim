CHANGELOG
=========

Starting from version `2.0.0` the plugin uses [semantic versionning 2.0.0](http://semver.org/).

2.3.0 <small>(2017-12-20)</small>
------------------------------

* Improve support of multiple docsets.
* Update the documentation.
* Some refactoring.
* Fix some issues.

### Features

* New option `g:zv_keep_focus` for keeping focus on vim after executing zeal.
* Support files with double extensions.
* New option `g:zv_zeal_args` to add arguments/flags to the execution's command.

------------------------------

2.2.0 <small>(2016-07-19)</small>
------------------------------

* Unify all commands into one unique `Zeavim`
* Refactoring
* Bug fixes

### Features

* New option `g:zv_get_docset_by` to set order/criteria(s) for docset finding

------------------------------

2.1.1 <small>(2016-05-18)</small>
------------------------------

* Internal refactoring: Unify the main zeal functions into one
* Remove deprecated option `g:zv_lazy_docset_list`

------------------------------

2.1.0 <small>(2016-01-13)</small>
------------------------------

* Internal refactoring

### Features

* New functionality: Search for a motion using `<Plug>ZVMotion`

------------------------------

2.0.1 <small>(2015-12-23)</small>
------------------------------

* DEGRADATION: Fix the issue where default mappings were not working
* Fix code example in the documentation

------------------------------

2.0.0 <small>(2015-12-23)</small>
------------------------------

* Big refactoring
* Update documentation and screens
* Add a version badge and use now semantic versionning

### Changes

* Remove `<Plug>ZVKeyword` and `ZvK` command, the functionality is natively supported by `<Plug>ZVKeyDocset`

### Features

* Supports docsets for specific file names
* Don't lose focus anymore on Unix if Zeal is opened (Needs wmtcrl)
* Allows using regex in `g:zv_file_types`
* Allows using multiple docsets with multiple completion for `Docset`

------------------------------

v1.4.4 <small>(2015-09-27)</small>
------------------------------

* Some refactoring
* Update documentation
* Add a CHANGELOG

### Changes

* Rename g:zv_added_files_type to g:zv_file_types
* Rename g:zv_zeal_directory to g:zv_zeal_executable

------------------------------

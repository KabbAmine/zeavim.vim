CHANGELOG
=========

Starting from version `2.0.0` the plugin uses [semantic versionning 2.0.0](http://semver.org/).

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

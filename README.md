# hacked - hacker's editor

hacked is [ncurses](https://invisible-island.net/ncurses/) based text editor written in [Chez Scheme](https://cisco.github.io/ChezScheme/). It may run on other Scheme implementations with some modifications.

## Goals

* Similar look and feel as [Emacs](https://www.gnu.org/software/emacs/)
* Lightweight, fast startup
* Full Lisp interpreter
* Fully customizable

## Getting Started

First, install Chez Scheme on your system using the package manager of your distro. For example, it is available as **chezscheme** for [Ubuntu](https://packages.ubuntu.com/hirsute/chezscheme) and as **chez-scheme** in [Arch Linux (AUR)]( https://aur.archlinux.org/packages/chez-scheme/).

Second, download and install the [chez-ncurses](https://github.com/akce/chez-ncurses) library. Create environment variable **CHEZSCHEMELIBDIRS** with the value of the directory where *ncurses.chezscheme.so* is located. Of course you also need to have **ncurses** itself installed.

Third, clone this repository on your machine.

Fourth, edit the executable file **hacked** and change the value of `hacked-directory` to the directory of the cloned repository.

Last, add **hacked** to your **PATH** environment variable so you can run it from any directory. You can just create a symlink in **~/bin** if that directory is already in your path.

## Usage

Just type `hacked` to run it:

```
$ hacked
```

You can also give filenames as arguments to open them for editing:

```
$ hacked file1.txt file2.txt
```

### Keybindings

If you are familiar with Emacs then you should feel right at home using hacked. Take a look at **bind.scm** to see a list of keybindings.

There is no plan to support [vim](https://www.vim.org/) style keybindings ("Evil Mode") at this time.

## Initialization File

The initialization file **~/.hacked** is automatically loaded at startup if it exists. You can put your own customizations there as Scheme code. Give the command line option **-q** to skip the loading of the init file.

## Status

Currently the editor is suitable for doing some quick and dirty editing in the terminal.

However, there are still some limitations:

* Only UTF-8 character encoding is supported
* Only Linux-style (\n) line endings are supported
* No wrapping of long lines
* No syntax highlighting
* No automatic indentation

## License

[GPLv3](https://bitbucket.org/maddy83/hacked/src/master/LICENSE)

For regular expressions the [pregexp](https://github.com/ds26gte/pregexp) library by Dorai Sitaram is included.

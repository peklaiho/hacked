# hacked - hacker's editor

hacked is ncurses based text editor written in Scheme. I have used [Chez Scheme](https://cisco.github.io/ChezScheme/) but possibly it may work on other Scheme implementations with some modifications.

The editor uses same key bindings as [Emacs](https://www.gnu.org/software/emacs/) by default. In fact, it is designed to be a light-weight alternative for Emacs when working in the terminal.

## Getting Started

Installing and running hacked is still a bit of a manual process as this is still a work-in-progress and has not been properly packaged for distribution. Here are the required steps to run it.

1. Installing Chez Scheme on your system using the package manager of your distro. For example, it is available as **chezscheme** for [Ubuntu](https://packages.ubuntu.com/hirsute/chezscheme) and as **chez-scheme** in [Arch Linux (AUR)]( https://aur.archlinux.org/packages/chez-scheme/).

2. Download and install the [chez-ncurses](https://github.com/akce/chez-ncurses) library according to their instructions. Create environment variable **CHEZSCHEMELIBDIRS** and set the value to the directory where *ncurses.chezscheme.so* is located. You can put that file in any directory you choose. Of course you also need to have **ncurses** itself installed on your system.

3. Clone this repository on your machine.

4. Edit the executable file **hacked** and change the value of **hacked-directory** to the directory of the cloned repo. This is a bit awkward but I did not find a better way of doing this yet. Should be fixed in the future.

5. Add hacked to your PATH environment variable. Usually you can just create a symlink in **~/bin** if that directory is already in your PATH.

Now you can run hacked from any directory:

```
$ hacked
```

You can also give filenames as arguments to open them for editing:

```
$ hacked file1.txt file2.txt
```

## Initialization File

The initialization file **~/.hacked** is automatically loaded at startup if it exists. You can put your own customizations there as Scheme code. You can give the command line option **-q** to skip the loading of the init file.

## Limitations

There are still many limitations in this early version:

* Only the UTF-8 character encoding is supported
* Only the Linux-style (\n) line ending is supported
* No wrapping of long lines
* No syntax highlighting

## License

[GPLv3](https://bitbucket.org/maddy83/hacked/src/master/LICENSE)

### Libraries

* [chez-ncurses](https://github.com/akce/chez-ncurses)
* [pregexp](https://github.com/ds26gte/pregexp) by Dorai Sitaram.

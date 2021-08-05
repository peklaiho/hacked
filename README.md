# hacked - hacker's editor

*hacked* is [ncurses](https://invisible-island.net/ncurses/) based text editor written in [Chez Scheme](https://cisco.github.io/ChezScheme/). It may run on other Scheme implementations with some modifications.

## Philosophy

Heavily influenced by [Emacs](https://www.gnu.org/software/emacs/), *hacked* is basically a Lisp interpreter with some text editing functions defined on top of it. Unlike most text editors, there is no configuration file with some pre-defined list of settings you can change. Everything is pure Scheme code without limitations. Therefore it is the ultimate *hacker's editor* in the sense that you can customize even the tiniest details to fit your personal preferences.

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

## Keys

If you are familiar with Emacs then you should feel right at home with the keybindings. `C` stands for Ctrl and `M` stands for Alt in this section.

* Exit program <kbd>C-q</kbd> or <kbd>C-x C-c</kbd>
* Eval Scheme code <kbd>M-x</kbd>

### Buffers and Files

* Open file <kbd>C-x C-f</kbd>
* Save buffer <kbd>C-x C-s</kbd>
* Kill buffer <kbd>C-x k</kbd>
* Select buffer <kbd>C-x b</kbd>
* Select next buffer <kbd>M-.</kbd> or <kbd>C-x &lt;right&gt;</kbd>, select previous buffer <kbd>M-,</kbd> or <kbd>C-x &lt;left&gt;</kbd>

### Movement

* Forward character <kbd>C-f</kbd>, backward character <kbd>C-b</kbd>
* Forward word <kbd>M-f</kbd>, backward word <kbd>M-b</kbd>
* Forward sentence <kbd>M-e</kbd>, backward sentence <kbd>M-a</kbd>
* Forward paragraph <kbd>M-}</kbd> or <kbd>M-n</kbd>, backward paragraph <kbd>M-{</kbd> or <kbd>M-p</kbd>
* Next line <kbd>C-n</kbd>, previous line <kbd>C-p</kbd>
* Begin of line <kbd>C-a</kbd>, end of line <kbd>C-e</kbd>
* Go to first non-whitespace character <kbd>M-m</kbd>
* Go to specific line <kbd>M-g</kbd>
* Begin of buffer <kbd>M-&lt;</kbd>, end of buffer <kbd>M-&gt;</kbd>
* Scroll one line or column with Ctrl and arrow keys
* Scroll page down <kbd>C-v</kbd>, scroll page up <kbd>M-v</kbd>
* Center current line on screen <kbd>C-l</kbd>
* Arrow keys, page up/down, home/end etc. work as expected

### Editing

* Delete character forward <kbd>C-d</kbd>
* Delete word forward <kbd>M-d</kbd>, delete word backward <kbd>M-&lt;backspace&gt;</kbd>
* Delete rest of line <kbd>C-k</kbd>
* Normal delete, backspace keys work as expected

You can create a region by using <kbd>C-&lt;space&gt;</kbd> to set a mark at the current location and then moving the cursor to another end of the region. Then you can use <kbd>C-w</kbd> to cut and <kbd>M-w</kbd> to copy the text of the selected region. Use <kbd>C-y</kbd> to paste the copied text. You can also exchange the position of mark and cursor with <kbd>C-x C-x</kbd>.

Note that unlike Emacs, deleting text by other means, such as <kbd>C-k</kbd> does not add it to the kill ring for paste. So you have to explicitly use <kbd>C-w</kbd> if you intend to paste it.

The editor has simple undo functionality using <kbd>C-/</kbd>, <kbd>C-_</kbd> or <kbd>C-x u</kbd>, but the undo just reverses the previous cut or paste operation and does not take into account other editing yet.

## Initialization File

The initialization file **~/.hacked** is automatically loaded at startup if it exists. You can put your own customizations there as Scheme code. Give the command line option **-q** to skip the loading of the init file.

## Tab Completion

Tab completion is supported when opening a file or selecting a buffer.

## Status

Currently *hacked* is suitable for doing some quick and dirty editing in the terminal.

However, there are still some limitations:

* Only UTF-8 character encoding is supported
* Only Linux-style (\n) line endings are supported
* No wrapping of long lines
* No syntax highlighting
* No automatic indentation

Some or all of these may be added during future development. The editor will not support splitting the view into multiple windows because I think [tmux](https://github.com/tmux/tmux) should be used for that instead. Also, there is no plan to support [vim](https://www.vim.org/) style keybindings ("Evil Mode") because it's probably better to just use vim (or [neovim](https://neovim.io/)) in that case.

## License

[GPLv3](https://bitbucket.org/maddy83/hacked/src/master/LICENSE)

For regular expressions the [pregexp](https://github.com/ds26gte/pregexp) library by Dorai Sitaram is included.

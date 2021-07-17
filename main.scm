(import
 (rnrs)
 (only (chezscheme) format)
 (ncurses))

;; Include files
(load "bind.scm")
(load "buffer.scm")
(load "draw.scm")
(load "func.scm")
(load "io.scm")
(load "key.scm")
(load "pregexp.scm")
(load "signal.scm")
(load "string.scm")
(load "util.scm")

 ;; Configure exception handler which closes ncurses
(with-exception-handler
 (lambda (ex) (endwin) (default-exception-handler ex))
 (lambda ()
   ;; Initializion of ncurses is described here:
   ;; https://invisible-island.net/ncurses/man/ncurses.3x.html
   (setlocale LC_ALL "")

   ;; Check that initscr was successful
   (let ([s (initscr)]) (assert (eq? s stdscr)))

   ;; Terminal settings, see:
   ;; https://invisible-island.net/ncurses/man/curs_inopts.3x.html
   (noecho)
   (raw)
   (meta stdscr #t)
   (intrflush stdscr #f)
   (keypad stdscr #t)

   ;; Enable color
   (start-color)
   (use-default-colors)
   (assume-default-colors -1 -1)
   (init-pair 1 COLOR_BLACK COLOR_WHITE)

   ;; Make a scratch buffer and set it as current
   (set! current-buffer
         (make-buffer
          "*scratch*"
          (read-file "~/alice.txt")))

   ;; Init bindings
   (bind-default-keys)

   ;; Draw screen
   (draw-screen)

   ;; Main loop
   (let loop ()
     (process-input)
     (draw-screen)
     (loop))
))

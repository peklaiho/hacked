(import
 (rnrs)
 (only (chezscheme) format)
 (ncurses))

;; Include files
(load "bind.scm")
(load "buffer.scm")
(load "draw.scm")
(load "func.scm")
(load "string.scm")

;; Open file for debugging
(define debug-file
  (open-file-output-port
   "~/debug.txt"
   (file-options no-fail)
   (buffer-mode none)
   (make-transcoder (utf-8-codec))))

;; Define some utility functions
(define debug-log
  (lambda (obj)
    (write obj debug-file)
    (newline debug-file)
    (flush-output-port debug-file)))

(define exit-program
  (lambda (exit-code)
    (endwin)
    (exit exit-code)))

(define min-max
  (lambda (val min max)
    (cond
     [(< val min) min]
     [(> val max) max]
     [else val])))

;; Initializion of ncurses is described here:
;; https://invisible-island.net/ncurses/man/ncurses.3x.html
(setlocale LC_ALL "")

;; Check that initscr was successful
(let ([s (initscr)]) (assert (eq? s stdscr)))

;; Turn on keypad so that KEY_RESIZE events are sent
(keypad stdscr #t)

;; Disable echo, line buffering and interrupt flush
(noecho)
(cbreak)
(intrflush stdscr #f)

;; Enable color
(start-color)
(use-default-colors)

;; Make a scratch buffer and set it as current
(set! current-buffer
      (make-buffer
       "*scratch*"
       "Some text written on the buffer...\nMore text on second line!\nThird line"))

;; Draw screen
(draw-screen)

;; Main loop
(let loop ([ch (getch)])
  (if (= ch KEY_RESIZE)
      (set! redraw-screen #t)
      (let ([f (binding-for-key ch)])
        (if f (f) #f)))
  (draw-screen)
  (loop (getch)))

(import
 (rnrs)
 (only (chezscheme) format)
 (ncurses))

;; Include files
(load "bind.scm")
(load "buffer.scm")
(load "draw.scm")
(load "func.scm")
(load "key.scm")
(load "pregexp.scm")
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

(define read-file
  (lambda (filename)
    (let* ([f (open-file-input-port
               filename
               (file-options)
               (buffer-mode block)
               (make-transcoder (utf-8-codec)))]
           [content (get-string-all f)])
      (close-port f)
      content)))

(define exit-program
  (case-lambda
   [() (exit-program 0)]
   [(exit-code)
    (endwin)
    (exit exit-code)]))

(define min-max
  (lambda (value minimum maximum)
    (min (max value minimum) maximum)))

;; Generate list of integers from i to j (inclusive)
(define range
  (lambda (i j)
    (map (lambda (n) (+ i n)) (iota (add1 (- j i))))))

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
          (read-file "bob.txt")))

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

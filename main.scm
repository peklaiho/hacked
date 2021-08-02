;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; hacked - hacker's editor
;; Copyright (c) 2021 Pekka Laiho
;; License: GPLv3
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
(load "minibuf.scm")
(load "pregexp.scm")
(load "signal.scm")
(load "string.scm")
(load "util.scm")

;; The editor can be in different modes of operation:
(define MODE_NORMAL #\N)
(define MODE_QUERY #\Q)
(define MODE_CONFIRM #\C)

(define current-mode MODE_NORMAL)

(define hacked-version "0.1")

;; Parse command-line arguments
(define arg-show-help #f)
(define arg-show-version #f)
(define arg-skip-init #f)
(define arg-load-files (list))

(let arg-loop ([args (cdr (command-line))])
  (when (not (null? args))
    (let ([arg (car args)])
      (cond
       [(or (string=? arg "--help") (string=? arg "-h"))
        (set! arg-show-help #t)]
       [(or (string=? arg "--version") (string=? arg "-v"))
        (set! arg-show-version #t)]
       [(or (string=? arg "--skip-init") (string=? arg "-q"))
        (set! arg-skip-init #t)]
       [else
        (set! arg-load-files (cons arg arg-load-files))]))
    (arg-loop (cdr args))))

(when arg-show-help
  (display "Usage:\n")
  (display "-h, --help         display this help\n")
  (display "-q, --skip-init    do not load init file (~/.hacked)\n")
  (display "-v, --version      display version number\n")
  (exit 0))

(when arg-show-version
  (display (format "hacked ~a\n" hacked-version))
  (exit 0))

;; Init bindings
(bind-default-keys)

;; Load init file
(unless arg-skip-init
  (let ([init-file
         (string-append
          (home-directory)
          (string (directory-separator))
          ".hacked")])
    (when (file-exists? init-file)
      (show-message (format "Load ~a" init-file) #f)
      (load init-file))))

;; Open files given from command line
(let file-loop ([files arg-load-files])
  (when (not (null? files))
    (let ([fname (resolve-absolute-filename (car files))])
      (cond
       [(and (file-exists? fname) (not (file-directory? fname)))
        (open-file fname)]
       [(and (file-exists? fname) (file-directory? fname))
        (show-message (format "~a is a directory" (compact-directory fname)))]
       [else
        (select-buffer (make-buffer (path-last fname) "" fname))]))
    (file-loop (cdr files))))

;; Make a scratch buffer if we did not open any files
(when (or (null? arg-load-files) (not current-buffer))
  (select-buffer (make-buffer "*scratch*")))

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

   ;; Draw screen
   (draw-screen)

   ;; Main loop
   (let loop ()
     (process-input)
     (draw-screen)
     (when (eq? current-mode MODE_NORMAL)
       (set! minibuffer-text ""))
     (loop))
))

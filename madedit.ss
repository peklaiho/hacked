(import
 (rnrs)
 (only (chezscheme) format)
 (ncurses))

(define-record-type buffer
  (fields
   (mutable name)
   (mutable content)
   (mutable point)))

(define advance-point
  (lambda (steps)
    (let ([old (buffer-point current-buffer)])
      (buffer-point-set! current-buffer (+ old steps)))))

(define binding-for-key
  (lambda (ch)
    (if (= ch (char->integer #\q))
        (lambda () (exit-program 0))
        (lambda () (insert-character-at-point ch)))))

(define current-buffer
  (make-buffer
   "*scratch*"
   "Some text written on the buffer...\nMore text on second line!\nThird line\n"
   0))

(define draw-screen
  (lambda (repaint)
    (if repaint (clear) (erase))
    (mvaddstr 0 (buffer-point current-buffer) (buffer-content current-buffer))
    (refresh)))

(define exit-program
  (lambda (exit-code)
    (endwin)
    (exit exit-code)))

(define insert-character-at-point
  (lambda (ch)
    (let* ([str (buffer-content current-buffer)]
           [len (string-length str)]
           [pt (buffer-point current-buffer)]
           [begin (substring str 0 pt)]
           [middle (string (integer->char ch))]
           [end (substring str pt len)])
      (buffer-content-set!
       current-buffer (string-append begin middle end))
      (advance-point 1)
      (draw-screen #f))))

;; Initializion of ncurses is described here:
;; https://invisible-island.net/ncurses/man/ncurses.3x.html
(setlocale LC_ALL "")

;; Initialize screen (for some reason we need define?)
(define main-screen (initscr))
(assert (eq? main-screen stdscr))

;; Turn on keypad so that KEY_RESIZE events are sent
(keypad stdscr #t)

;; Disable echo, line buffering and interrupt flush
(noecho)
(cbreak)
(intrflush stdscr #f)

;; Enable color
(start-color)
(use-default-colors)

;; Draw screen
(draw-screen #t)

;; Main loop
(let loop ([ch (getch)])
  (if (= ch KEY_RESIZE)
      (draw-screen #t)
      (let ([f (binding-for-key ch)])
        (f)))
  (loop (getch)))

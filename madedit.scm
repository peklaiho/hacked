(import
 (rnrs)
 (only (chezscheme) format)
 (ncurses))

;; -----
;; Utils
;; -----

(define exit-program
  (lambda (exit-code)
    (endwin)
    (exit exit-code)))

;; -------
;; Buffers
;; -------

(define-record-type buffer
  (fields
   (mutable name)
   (mutable content)
   (mutable point)))

(define current-buffer #f)

;; Define some shortcuts for operating on the current buffer
;; because they are used so frequently!

(define current-name
  (lambda ()
    (buffer-name current-buffer)))

(define current-content
  (lambda ()
    (buffer-content current-buffer)))

(define current-content-set!
  (lambda (val)
    (buffer-content-set! current-buffer val)
    #t))

(define current-length
  (lambda ()
    (string-length (buffer-content current-buffer))))

(define current-point
  (lambda ()
    (buffer-point current-buffer)))

(define current-substring
  (lambda (start end)
    (substring (current-content) start end)))

;; Create new buffer and set it as current
(define new-buffer
  (lambda (name content)
    (set! current-buffer
          (make-buffer name content 0))))

;; Move point forward or backward (negative arg)
;; Return #t if the position changed, otherwise false
(define point-advance
  (lambda (n)
    (let ([old (current-point)])
      (point-set (+ (buffer-point current-buffer) n))
      (not (= old (current-point))))))

;; Set point to new value, checking bounds
(define point-set
  (lambda (n)
    (buffer-point-set!
     current-buffer
     (cond
      [(< n 0) 0]
      [(> n (current-length)) (current-length)]
      [else n]))
    #t))

;; ------
;; Render
;; ------

(define redraw-screen #t)
(define last-key #f)

(define draw-screen
  (lambda ()
    (if redraw-screen (clear) (erase))
    (set! redraw-screen #f)
    (mvaddstr 0 0 (buffer-content current-buffer))
    (draw-minibuf)
    (when last-key (draw-last-key))
    (refresh)))

(define draw-minibuf
  (lambda ()
    (mvaddstr
     (- LINES 2) 0
     (format " Point: ~d, Screen: ~dx~d"
             (current-point) COLS LINES))))

(define draw-last-key
  (lambda ()
    (let ([ch last-key])
      (mvaddstr
       (- LINES 1) 0
       (format "Octal: ~o, Decimal: ~d, Hex: ~x, Char: ~c" ch ch ch (integer->char ch))))))

;; --------
;; Bindings
;; --------

(define binding-for-key
  (lambda (ch)
    (set! last-key ch)
    (cond
     [(= ch KEY_LEFT)
      (lambda () (point-advance -1))]
     [(= ch KEY_RIGHT)
      (lambda () (point-advance 1))]
     [(= ch KEY_DC)
      (lambda () (delete-character-forward))]
     [(or (= ch KEY_BACKSPACE) (= ch 127))
      (lambda () (delete-character-backward))]
     [(= ch (char->integer #\q))
      (lambda () (exit-program 0))]
     [else
      (lambda () (insert-character-adv-point ch))])))

;; -------
;; Editing
;; -------

(define delete-character
  (lambda (idx)
    (if (or (< idx 0) (>= idx (current-length))) #f
        (current-content-set!
         (string-append
          (current-substring 0 idx)
          (current-substring (add1 idx) (current-length)))))))

(define delete-character-forward
  (lambda ()
    (delete-character (current-point))))

(define delete-character-backward
  (lambda ()
    (if (point-advance -1) (delete-character-forward) #f)))

(define insert-character
  (lambda (ch idx)
    (insert-string (string (integer->char ch)) idx)))

(define insert-character-at-point
  (lambda (ch)
    (insert-character ch (current-point))))

;; Insert and advance point
(define insert-character-adv-point
  (lambda (ch)
    (insert-character-at-point ch)
    (point-advance 1)))

(define insert-string
  (lambda (txt idx)
    (current-content-set!
     (string-append
      (current-substring 0 idx)
      txt
      (current-substring idx (current-length))))))

(define insert-string-at-point
  (lambda (txt)
    (insert-string txt (current-point))))

;; ---
;; Initializion of ncurses is described here:
;; https://invisible-island.net/ncurses/man/ncurses.3x.html
;; ---

(setlocale LC_ALL "")
(let ([win (initscr)])
  ;; Check that initscr was successful
  (assert (eq? win stdscr))

  ;; Turn on keypad so that KEY_RESIZE events are sent
  (keypad stdscr #t)

  ;; Disable echo, line buffering and interrupt flush
  (noecho)
  (cbreak)
  (intrflush stdscr #f)

  ;; Enable color
  (start-color)
  (use-default-colors)

  ;; Make a scratch buffer
  (new-buffer
   "*scratch*"
   "Some text written on the buffer...\nMore text on second line!\nThird line")

  (draw-screen)
)

;; Main loop
(let loop ([ch (getch)])
  (if (= ch KEY_RESIZE)
      (set! redraw-screen #t)
      (let ([f (binding-for-key ch)])
        (if f (f) #f)))
  (draw-screen)
  (loop (getch)))

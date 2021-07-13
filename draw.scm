(define redraw-screen #t)

(define minibuffer-text "")

(define draw-screen
  (lambda ()
    (if redraw-screen (clear) (erase))
    (set! redraw-screen #f)
    (draw-buffer)
    (draw-statusbar)
    (draw-minibuffer)
    (move (- (buffer-line) (buffer-offset-line))
          (- (buffer-column) (buffer-offset-column)))
    (refresh)))

(define draw-buffer
  (lambda ()
    (color-set 0 0)
    (call/cc
     (lambda (break)
       (let loop ([i 0])
         (when (> i (last-buffer-line))
           (break i))
         (let ([line (buffer-line-index (+ i (buffer-offset-line)))])
           (when (not line)
             (break i))
           (let* ([start (+ (car line) (buffer-offset-column))]
                  [end (cdr line)]
                  [content (string-truncate (buffer-substring start end) COLS)])
             (mvaddstr i 0 content)
             (loop (add1 i)))))))))

(define statusbar-content
  (lambda ()
    (format "~3d:~2d g~2d o~3d:~2d    ~a"
            (add1 (buffer-line))
            (buffer-column)
            (buffer-goal-column)
            (buffer-offset-line)
            (buffer-offset-column)
            (buffer-name))))

(define draw-statusbar
  (lambda ()
    (color-set 1 0)
    (let* ([content (statusbar-content)]
           [fill (- COLS (string-length content))])
      (when (> fill 0)
        (set! content (string-append content (make-string fill #\space))))
      (mvaddstr (statusbar-line) 0 content))))

(define draw-minibuffer
  (lambda ()
    (color-set 0 0)
    (mvaddstr (minibuffer-line) 0 (string-truncate minibuffer-text COLS))
    (set! minibuffer-text "")))

(define show-on-minibuf
  (lambda (txt . args)
    (set! minibuffer-text (apply format txt args))))

(define screen-size-changed
  (lambda ()
    (debug-log (format "RESIZE => Cols: ~d, Lines: ~d" COLS LINES))
    (set! redraw-screen #t)
    (reconcile-by-scrolling)))

;; Number of lines reserved for buffer.
(define lines-for-buffer
  (lambda ()
    (- LINES 2)))

(define last-buffer-line
  (lambda ()
    (- LINES 3)))

(define last-buffer-column
  (lambda ()
    (- COLS 1)))

(define statusbar-line
  (lambda ()
    (- LINES 2)))

(define minibuffer-line
  (lambda ()
    (- LINES 1)))

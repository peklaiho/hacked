(define redraw-screen #t)

(define draw-screen
  (lambda ()
    (if redraw-screen (clear) (erase))
    (set! redraw-screen #f)
    (draw-buffer)
    (draw-statusbar)
    (move (- (buffer-line) (buffer-offset)) (buffer-column))
    (refresh)))

(define draw-buffer
  (lambda ()
    (color-set 0 0)
    (call/cc
     (lambda (break)
       (let loop ([i 0])
         (when (> i (- LINES 3))
           (break i))
         (let ([line (buffer-line-index (+ i (buffer-offset)))])
           (when (not line)
             (break i))
           (let ([content (buffer-substring (car line) (cdr line))])
             (mvaddstr i 0 content)
             (loop (add1 i)))))))))

(define statusbar-content
  (lambda ()
    (format "~3d:~2d g~d o~d    ~a"
            (add1 (buffer-line))
            (buffer-column)
            (buffer-goal-column)
            (buffer-offset)
            (buffer-name))))

(define draw-statusbar
  (lambda ()
    (color-set 1 0)
    (let* ([content (statusbar-content)]
           [fill (- COLS (string-length content))])
      (when (> fill 0)
        (set! content (string-append content (make-string fill #\space))))
      (mvaddstr (- LINES 2) 0 content))))

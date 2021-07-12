(define redraw-screen #t)

(define draw-screen
  (lambda ()
    (if redraw-screen (clear) (erase))
    (set! redraw-screen #f)
    (draw-buffer)
    (draw-statusbar)
    (move (- (buffer-line) (buffer-offset-line))
          (- (buffer-column) (buffer-offset-column)))
    (refresh)))

(define draw-buffer
  (lambda ()
    (color-set 0 0)
    (call/cc
     (lambda (break)
       (let loop ([i 0])
         (when (> i (last-line))
           (break i))
         (let ([line (buffer-line-index (+ i (buffer-offset-line)))])
           (when (not line)
             (break i))
           (let* ([start (+ (car line) (buffer-offset-column))]
                  [end (min (cdr line) (+ start (columns-for-buffer)))]
                  [content (buffer-substring start end)])
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
      (mvaddstr (lines-for-buffer) 0 content))))

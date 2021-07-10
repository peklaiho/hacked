(define redraw-screen #t)

(define draw-screen
  (lambda ()
    (if redraw-screen (clear) (erase))
    (set! redraw-screen #f)
    (mvaddstr 0 0 (buffer-content))
    (draw-minibuf)
    (refresh)))

(define draw-minibuf
  (lambda ()
    (mvaddstr
     (- LINES 2) 0
     (format "Point: ~d, Column: ~d, Goal: ~d, Line: ~d (~d:~d), Screen: ~dx~d, Length: ~d"
             (buffer-point)
             (buffer-column)
             (buffer-goal-column)
             (buffer-line)
             (car (buffer-line-index))
             (cdr (buffer-line-index))
             COLS LINES
             (buffer-length)))))

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
     (format "Point: ~d, Screen: ~dx~d, Length: ~d"
             (buffer-point) COLS LINES (buffer-length)))))

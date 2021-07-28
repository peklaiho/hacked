;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; hacked - hacker's editor
;; Copyright (c) 2021 Pekka Laiho
;; License: GPLv3
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(define redraw-screen #t)

(define draw-screen
  (lambda ()
    (if redraw-screen (clear) (erase))
    (set! redraw-screen #f)
    (draw-buffer)
    (draw-statusbar)
    (draw-minibuffer)
    (draw-cursor)
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
           (let* ([start (min (cdr line) (+ (car line) (buffer-offset-column)))]
                  [end (cdr line)]
                  [content (string-truncate (buffer-substring start end) COLS)])
             (mvaddstr i 0 content)
             (loop (add1 i)))))))))

(define statusbar-content
  (lambda ()
    (let* ([begin (format "~3d:~2d  ~a  ~a"
                         (add1 (buffer-line))
                        (buffer-column)
                        (if (buffer-modified) "*" " ")
                        (buffer-name))]
           [end (format "hacked ~a " hacked-version)]
           [fill (make-string (- COLS (string-length begin) (string-length end)) #\space)])
      (string-append begin fill end))))

(define draw-statusbar
  (lambda ()
    (color-set 1 0)
    (mvaddstr (statusbar-line) 0 (statusbar-content))))

(define draw-minibuffer
  (lambda ()
    (color-set 0 0)
    (mvaddstr (minibuffer-line) 0
              (string-truncate
               (minibuffer-text-to-draw) (sub1 COLS)))))

(define draw-cursor
  (lambda ()
    (cond
      [(eq? current-mode MODE_QUERY)
       (move (minibuffer-line) (string-length (minibuffer-text-to-draw)))]
      [else
       (move (- (buffer-line) (buffer-offset-line))
             (- (buffer-column) (buffer-offset-column)))])))

(define screen-size-changed
  (lambda ()
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

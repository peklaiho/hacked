(define minibuffer-text "")
(define minibuffer-input "")
(define minibuffer-continuation #f)
(define minibuffer-completion #f)

(define show-on-minibuf
  (lambda (txt . args)
    (set! minibuffer-text (apply format txt args))))

(define perform-query
  (lambda (txt initial-input cont comp-fn)
    (set! current-mode MODE_QUERY)
    (set! minibuffer-text txt)
    (set! minibuffer-input initial-input)
    (set! minibuffer-continuation cont)
    (set! minibuffer-completion comp-fn)))

(define minibuffer-text-to-draw
  (lambda ()
    (if (eq? current-mode MODE_QUERY)
        (string-append minibuffer-text minibuffer-input)
        minibuffer-text)))

(define minibuf-process-input
  (lambda (keycode)
    (cond
     [(or (= keycode 10) (= keycode 13))
      ;; Enter, call the continuation
      (set! current-mode MODE_NORMAL)
      (set! minibuffer-text "")
      (minibuffer-continuation minibuffer-input)]
     [(= keycode 127)
      ;; Backspace
      (when (> (string-length minibuffer-input) 0)
        (set! minibuffer-input
              (substring minibuffer-input 0
                         (sub1 (string-length minibuffer-input)))))]
     [(and (> keycode 31) (< keycode 256))
      ;; Normal key?
      (set! minibuffer-input
            (string-append minibuffer-input
                           (string (integer->char keycode))))]
     [else
      ;; Some control key, don't do anything...
      #f])))

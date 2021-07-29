;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; hacked - hacker's editor
;; Copyright (c) 2021 Pekka Laiho
;; License: GPLv3
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
     ;; Tab
     [(= keycode 9)
      (when minibuffer-completion
        (let ([completions (minibuffer-completion minibuffer-input)])
          (add-to-messages "Completions for ~a: ~s" minibuffer-input completions)
          ;; For now we just handle one completion
          (when (= (length completions) 1)
            (set! minibuffer-input (car completions)))))]

     ;; Enter
     [(or (= keycode 10) (= keycode 13))
      ;; Enter, call the continuation
      (set! current-mode MODE_NORMAL)
      (set! minibuffer-text "")
      (minibuffer-continuation minibuffer-input)]

     ;; Backspace
     [(= keycode 127)
      (when (> (string-length minibuffer-input) 0)
        (set! minibuffer-input
              (substring minibuffer-input 0
                         (sub1 (string-length minibuffer-input)))))]

     ;; Alt-backspace
     [(= keycode (bitwise-ior 127 MOD_ALT))
      (when (> (string-length minibuffer-input) 0)
        (let ([i (string-find-char-sequence
                  minibuffer-input
                  word-boundary
                  (sub1 (string-length minibuffer-input))
                  #f)])
          (when (not i) (set! i 0))
          (set! minibuffer-input
                (substring minibuffer-input 0 i))))]

     ;; Normal key?
     [(and (> keycode 31) (< keycode 256))
      (set! minibuffer-input
            (string-append minibuffer-input
                           (string (integer->char keycode))))]

     ;; Something else, ignore for now
     [else #f])))

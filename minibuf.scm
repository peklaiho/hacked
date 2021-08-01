;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; hacked - hacker's editor
;; Copyright (c) 2021 Pekka Laiho
;; License: GPLv3
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(define minibuffer-text "")

;; Query mode variables
(define minibuffer-input "")
(define minibuffer-continuation #f)
(define minibuffer-completion #f)

;; Confirm mode variables
(define minibuffer-confirm-yes #f)
(define minibuffer-confirm-no #f)

(define show-on-minibuf
  (lambda (message)
    (set! minibuffer-text message)))

(define perform-query
  (lambda (txt initial-input cont comp-fn)
    (set! current-mode MODE_QUERY)
    (set! minibuffer-text txt)
    (set! minibuffer-input initial-input)
    (set! minibuffer-continuation cont)
    (set! minibuffer-completion comp-fn)))

(define perform-confirm
  (lambda (txt yes-fn no-fn)
    (set! current-mode MODE_CONFIRM)
    (set! minibuffer-text txt)
    (set! minibuffer-confirm-yes yes-fn)
    (set! minibuffer-confirm-no no-fn)))

(define minibuffer-text-to-draw
  (lambda ()
    (if (eq? current-mode MODE_QUERY)
        (string-append minibuffer-text minibuffer-input)
        minibuffer-text)))

(define minibuf-show-completions
  (lambda (completions)
    (let ([buf (find-or-make-buffer "*completions*")])
      (buffer-content-set!
       buf (if (null? completions) "(no completions)"
               (string-join completions (buffer-newline-char buf))))
      (select-buffer buf))))

(define minibuf-hide-completions
  (lambda ()
    (let ([buf (find-buffer "*completions*")])
      (when buf (kill-buffer buf)))))

(define minibuf-process-input-confirm
  (lambda (keycode)
    (cond
     [(or (= keycode 89) (= keycode 121))
      (set! current-mode MODE_NORMAL)
      (set! minibuffer-text "")
      (if minibuffer-confirm-yes (minibuffer-confirm-yes) #f)]
     [(or (= keycode 78) (= keycode 110))
      (set! current-mode MODE_NORMAL)
      (set! minibuffer-text "")
      (if minibuffer-confirm-no (minibuffer-confirm-no) #f)]
     [else #f])))

(define minibuf-process-input-query
  (lambda (keycode)
    (cond
     ;; Tab
     [(= keycode 9)
      (when minibuffer-completion
        (let ([completions (minibuffer-completion minibuffer-input)])
          (if (= (length completions) 1)
              (begin
                (minibuf-hide-completions)
                (set! minibuffer-input (car completions)))
              (minibuf-show-completions completions))))]

     ;; Enter
     [(or (= keycode 10) (= keycode 13))
      ;; Enter, call the continuation
      (set! current-mode MODE_NORMAL)
      (set! minibuffer-text "")
      (minibuf-hide-completions)
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

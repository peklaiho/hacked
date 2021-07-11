(define binding-for-key
  (lambda (key)
    (debug-log (format "KEY -> Octal: ~o, Decimal: ~d, Hex: ~x, Char: ~c" key key key (integer->char key)))
    (cond

     ;; Movement
     [(= key KEY_LEFT)
      (lambda () (backward-character))]
     [(= key KEY_RIGHT)
      (lambda () (forward-character))]
     [(= key KEY_UP)
      (lambda () (backward-line))]
     [(= key KEY_DOWN)
      (lambda () (forward-line))]
     [(= key KEY_HOME)
      (lambda () (begin-of-line))]
     [(= key KEY_END)
      (lambda () (end-of-line))]

     [(= key (char->integer #\<))
      (lambda () (begin-of-buffer))]
     [(= key (char->integer #\>))
      (lambda () (end-of-buffer))]

     ;; Scrolling
     [(= key (char->integer #\w))
      (lambda () (scroll-up))]
     [(= key (char->integer #\s))
      (lambda () (scroll-down))]
     [(= key (char->integer #\a))
      (lambda () (scroll-left))]
     [(= key (char->integer #\d))
      (lambda () (scroll-right))]

     [(= key KEY_PPAGE)
      (lambda () (scroll-page-up))]
     [(= key KEY_NPAGE)
      (lambda () (scroll-page-down))]

     [(= key (char->integer #\t))
      (lambda () (scroll-current-line-top))]
     [(= key (char->integer #\b))
      (lambda () (scroll-current-line-bottom))]
     [(= key (char->integer #\m))
      (lambda () (scroll-current-line-middle))]

     ;; Deletion
     [(= key KEY_DC)
      (lambda () (delete-character-forward))]
     [(or (= key 127) (= key KEY_BACKSPACE))
      (lambda () (delete-character-backward))]

     [(= key (char->integer #\q))
      (lambda () (exit-program 0))]
     [else
      (lambda () (insert-character-forward (integer->char key)))])))

(define read-input
  (lambda ()
    (getch)))

(define process-input
  (lambda ()
    (let ([key (read-input)])
      (if (= key KEY_RESIZE) (screen-size-changed)
          (let ([f (binding-for-key key)])
            (if f (f) #f))))))

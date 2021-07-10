(define binding-for-key
  (lambda (key)
    (debug-log (format "KEY -> Octal: ~o, Decimal: ~d, Hex: ~x, Char: ~c" key key key (integer->char key)))
    (cond
     [(= key KEY_LEFT)
      (lambda () (backward-character))]
     [(= key KEY_RIGHT)
      (lambda () (forward-character))]
     [(= key KEY_UP)
      (lambda () (backward-line))]
     [(= key KEY_DOWN)
      (lambda () (forward-line))]
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
      (if (= key KEY_RESIZE) (set! redraw-screen #t)
          (let ([f (binding-for-key key)])
            (if f (f) #f))))))

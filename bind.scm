(define binding-for-key
  (lambda (ch)
    (debug-log (format "KEY -> Octal: ~o, Decimal: ~d, Hex: ~x, Char: ~c" ch ch ch (integer->char ch)))
    (cond
     [(= ch KEY_LEFT)
      (lambda () (advance-point -1))]
     [(= ch KEY_RIGHT)
      (lambda () (advance-point 1))]
     [(= ch KEY_DC)
      (lambda () (delete-character-forward))]
     [(or (= ch 127) (= ch KEY_BACKSPACE))
      (lambda () (delete-character-backward))]
     [(= ch (char->integer #\q))
      (lambda () (exit-program 0))]
     [else
      (lambda () (insert-character-adv-point (integer->char ch)))])))

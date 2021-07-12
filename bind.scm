(define make-key-map
  (lambda ()
    (make-hashtable (lambda (a) a) eq?)))

(define global-key-map (make-key-map))

(define global-set-key
  (case-lambda
   [(keycode fname) (global-set-key keycode fname #f)]
   [(keycode fname arg)
    (when (or (< keycode 128) (> keycode 170))
      (debug-log (format "BIND   => ~d ~a :: ~a ~s" keycode (keycode->string keycode) fname arg)))
    (hashtable-set! global-key-map keycode (cons fname arg))]))

(define resolve-binding
  (lambda (keycode)
    (let ([bind (hashtable-ref global-key-map keycode #f)])
      (if bind
          (debug-log
           (format
            "FOUND  => ~d ~a :: ~s"
            keycode (keycode->string keycode) bind))
          (debug-log
           (format
            "NOBIND => ~d ~a"
            keycode (keycode->string keycode))))
      bind)))

(define bind-default-keys
  (lambda ()
    ;; Bind all normal keys
    (for-each
     (lambda (i)
       (global-set-key i 'insert-character-forward (integer->char i)))
     (range 33 126))

    ;; Bind extended keys
    (for-each
     (lambda (i)
       (global-set-key i 'insert-character-forward (integer->char i)))
     (range 128 255))

    ;; Quit
    (global-set-key (string->keycode "C-q") 'exit-program)

    ;; Movement
    (global-set-key (string->keycode "<left>") 'backward-character)
    (global-set-key (string->keycode "<right>") 'forward-character)
    (global-set-key (string->keycode "<up>") 'backward-line)
    (global-set-key (string->keycode "<down>") 'forward-line)
    (global-set-key (string->keycode "<home>") 'begin-of-line)
    (global-set-key (string->keycode "<end>") 'end-of-line)

    (global-set-key (string->keycode "C-b") 'backward-character)
    (global-set-key (string->keycode "C-f") 'forward-character)
    (global-set-key (string->keycode "C-p") 'backward-line)
    (global-set-key (string->keycode "C-n") 'forward-line)
    (global-set-key (string->keycode "C-a") 'begin-of-line)
    (global-set-key (string->keycode "C-e") 'end-of-line)

    ;; Scrolling
    (global-set-key (string->keycode "C-<left>") 'scroll-left)
    (global-set-key (string->keycode "C-<right>") 'scroll-right)
    (global-set-key (string->keycode "C-<up>") 'scroll-up)
    (global-set-key (string->keycode "C-<down>") 'scroll-down)

    (global-set-key (string->keycode "<prior>") 'scroll-page-up)
    (global-set-key (string->keycode "<next>") 'scroll-page-down)

    (global-set-key (string->keycode "C-<prior>") 'scroll-current-line-bottom)
    (global-set-key (string->keycode "C-<next>") 'scroll-current-line-top)
    (global-set-key (string->keycode "C-l") 'scroll-current-line-middle)

    ;; Editing
    (global-set-key (string->keycode "<enter>") 'insert-character-forward #\newline)
    (global-set-key (string->keycode "<return>") 'insert-character-forward #\newline)

    (global-set-key (string->keycode "<space>") 'insert-character-forward #\space)

    (global-set-key (string->keycode "<backspace>") 'delete-character-backward)
    (global-set-key (string->keycode "<delete>") 'delete-character-forward)
    (global-set-key (string->keycode "C-d") 'delete-character-forward)
))

(define read-input
  (lambda ()
    (let ([key (getch)])
      (let ([keycode (parse-terminal-key key #f)])
        (debug-log (format "KEY    => Octal: ~o, Dec: ~d, Hex: ~x, Ch: ~c, Code: ~d, String: ~a"
                           key key key (integer->char key)
                           keycode (keycode->string keycode)))
        keycode))))

(define process-input
  (lambda ()
    (let ([keycode (read-input)])
      (if (= keycode KEY_RESIZE)
          (screen-size-changed)
          (let ([bind (resolve-binding keycode)])
            (when bind
              (let ([fn (eval (car bind))] [arg (cdr bind)])
                (if arg (fn arg) (fn)))))))))

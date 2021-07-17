;; ---------------------------
;; Basic functions for keymaps
;; ---------------------------

(define make-key-map
  (lambda ()
    (make-hashtable (lambda (a) a) =)))

(define key-map?
  (lambda (a)
    (hashtable? a)))

(define key-map-find
  (lambda (kmap keycode)
    (hashtable-ref kmap keycode #f)))

;; Find given keycodes from key-map recursively.
(define key-map-find-recursively
  (lambda (kmap keycodes)
    (let ([result (key-map-find kmap (car keycodes))])
      (if (null? (cdr keycodes)) result
          (if (and result (key-map? result))
              (key-map-find-recursively result (cdr keycodes))
              #f)))))

;; Set the given keycodes recursively,
;; creating nested key-maps as needed.
(define key-map-set!
  (lambda (kmap keycodes value)
    (let ([first (car keycodes)] [rest (cdr keycodes)])
      (if (null? rest)
          ;; This is last key, just set it
          (hashtable-set! kmap first value)
          ;; We have more keys
          (let ([old (key-map-find kmap first)])
            (if (and old (key-map? old))
                ;; We have old hashmap, use it
                (key-map-set! old rest value)
                ;; Make new keymap
                (let ([new-kmap (make-key-map)])
                  (hashtable-set! kmap first new-kmap)
                  (key-map-set! new-kmap rest value))))))))

;; -------------
;; Global keymap
;; -------------

(define global-key-map (make-key-map))

(define global-set-key
  (case-lambda
   [(keycodes fname) (global-set-key keycodes fname #f)]
   [(keycodes fname arg) (key-map-set! global-key-map keycodes (cons fname arg))]))

;; -------------
;; Process input
;; -------------

(define current-keycodes '())

(define process-current-input
  (lambda ()
    (let ([bind (key-map-find-recursively global-key-map current-keycodes)])
      (cond
       [(not bind)
        (show-on-minibuf "Key ~a is not bound"
                         (keycodes->string current-keycodes))
        (set! current-keycodes '())]
       [(key-map? bind)
        (show-on-minibuf (keycodes->string current-keycodes))]
       [else
        (let ([fn (eval (car bind))] [arg (cdr bind)])
          (set! current-keycodes '())
          (if arg (fn arg) (fn)))]))))

(define process-input
  (lambda ()
    (let ([keycode (read-input)])
      (cond
       [(= keycode KEY_RESIZE)
        (screen-size-changed)]
       [(= keycode quit-key)
        (set! current-keycodes '())
        (show-on-minibuf "Quit")]
       [else
        (set! current-keycodes (append current-keycodes (list keycode)))
        (process-current-input)]))))

;; ----------------
;; Default bindings
;; ----------------

(define bind-default-keys
  (lambda ()
    ;; Bind all normal keys
    (for-each
     (lambda (i)
       (global-set-key (list i) 'insert-character-forward (integer->char i)))
     (range 33 126))

    ;; Bind extended keys
    (for-each
     (lambda (i)
       (global-set-key (list i) 'insert-character-forward (integer->char i)))
     (range 128 255))

    ;; Quit
    (global-set-key (string->keycodes "C-q") 'exit-program)
    (global-set-key (string->keycodes "C-x C-c") 'exit-program)

    ;; Movement
    (global-set-key (string->keycodes "<left>") 'backward-character)
    (global-set-key (string->keycodes "<right>") 'forward-character)
    (global-set-key (string->keycodes "<up>") 'backward-line)
    (global-set-key (string->keycodes "<down>") 'forward-line)
    (global-set-key (string->keycodes "<home>") 'begin-of-line)
    (global-set-key (string->keycodes "<end>") 'end-of-line)

    (global-set-key (string->keycodes "C-b") 'backward-character)
    (global-set-key (string->keycodes "C-f") 'forward-character)
    (global-set-key (string->keycodes "C-p") 'backward-line)
    (global-set-key (string->keycodes "C-n") 'forward-line)
    (global-set-key (string->keycodes "C-a") 'begin-of-line)
    (global-set-key (string->keycodes "C-e") 'end-of-line)

    (global-set-key (string->keycodes "M-b") 'backward-word)
    (global-set-key (string->keycodes "M-f") 'forward-word)
    (global-set-key (string->keycodes "M-p") 'backward-paragraph)
    (global-set-key (string->keycodes "M-n") 'forward-paragraph)
    (global-set-key (string->keycodes "M-{") 'backward-paragraph)
    (global-set-key (string->keycodes "M-}") 'forward-paragraph)

    (global-set-key (string->keycodes "M-<") 'begin-of-buffer)
    (global-set-key (string->keycodes "M->") 'end-of-buffer)
    (global-set-key (string->keycodes "C-<home>") 'begin-of-buffer)
    (global-set-key (string->keycodes "C-<end>") 'end-of-buffer)

    ;; Scrolling
    (global-set-key (string->keycodes "C-<left>") 'scroll-left)
    (global-set-key (string->keycodes "C-<right>") 'scroll-right)
    (global-set-key (string->keycodes "C-<up>") 'scroll-up)
    (global-set-key (string->keycodes "C-<down>") 'scroll-down)

    (global-set-key (string->keycodes "<prior>") 'scroll-page-up)
    (global-set-key (string->keycodes "<next>") 'scroll-page-down)

    (global-set-key (string->keycodes "M-v") 'scroll-page-up)
    (global-set-key (string->keycodes "C-v") 'scroll-page-down)
    (global-set-key (string->keycodes "C-l") 'scroll-current-line-middle)

    ;; Editing
    (global-set-key (string->keycodes "<enter>") 'insert-character-forward #\newline)
    (global-set-key (string->keycodes "<return>") 'insert-character-forward #\newline)
    (global-set-key (string->keycodes "<space>") 'insert-character-forward #\space)

    (global-set-key (string->keycodes "<backspace>") 'delete-character-backward)
    (global-set-key (string->keycodes "<delete>") 'delete-character-forward)
    (global-set-key (string->keycodes "C-d") 'delete-character-forward)
))

(define CTRL_MASK 2048)
(define ALT_MASK 4096)

(define parse-control-character
  (lambda (key)
    (cond
     ;; Return/Enter
     [(or (= key 10) (= key 13))
      (cons #f key)]

     ;; C-a to C-z
     [(and (>= key 1) (<= key 26))
      (cons #t (+ key 96))]
     ;; C-h is different for some reason
     [(= key 263) (cons #t 104)]
     ;; Control with numbers: C-4 to C-7
     [(and (>= key 28) (<= key 31))
      (cons #t (+ key 24))]

     ;; Function keys
     [(and (>= key 289) (<= key 300))
      (cons #t (- key 24))]

     ;; Arrow keys
     [(= key 546) (cons #t KEY_LEFT)]
     [(= key 561) (cons #t KEY_RIGHT)]
     [(= key 567) (cons #t KEY_UP)]
     [(= key 526) (cons #t KEY_DOWN)]

     ;; Home etc.
     [(= key 536) (cons #t KEY_HOME)]
     [(= key 531) (cons #t KEY_END)]
     [(= key 520) (cons #t KEY_DC)]
     [(= key 556) (cons #t KEY_PPAGE)]
     [(= key 551) (cons #t KEY_NPAGE)]

     ;; Not control
     [else (cons #f key)]
    )))

(define parse-terminal-key
  (lambda (raw-key is-alt)
    (let* ([result (parse-control-character raw-key)]
           [is-ctrl (car result)]
           [raw-key (cdr result)])
      (+ raw-key
         (if is-ctrl CTRL_MASK 0)
         (if is-alt ALT_MASK 0)))))

(define keycode-alt?
  (lambda (key)
  (>= key ALT_MASK)))

(define keycode-ctrl?
  (lambda (key)
    (>= (if (keycode-alt? key) (- key ALT_MASK) key) CTRL_MASK)))

(define keycode-base-value
  (lambda (key)
    (- key (if (keycode-alt? key) ALT_MASK 0)
       (if (keycode-ctrl? key) CTRL_MASK 0))))

(define keycode->string
  (lambda (keycode)
    (let ([key (keycode-base-value keycode)])
      (format "~a~a~a"
       (if (keycode-ctrl? keycode) "C-" "")
       (if (keycode-alt? keycode) "M-" "")
       (cond
        [(= key 10) "<enter>"]
        [(= key 13) "<return>"]
        [(= key 27) "<escape>"]
        [(= key 32) "<space>"]
        [(= key 127) "<backspace>"]

        [(= key KEY_LEFT) "<left>"]
        [(= key KEY_RIGHT) "<right>"]
        [(= key KEY_UP) "<up>"]
        [(= key KEY_DOWN) "<down>"]

        [(= key KEY_HOME) "<home>"]
        [(= key KEY_END) "<end>"]
        [(= key KEY_IC) "<insert>"]
        [(= key KEY_DC) "<delete>"]
        [(= key KEY_PPAGE) "<prior>"]
        [(= key KEY_NPAGE) "<next>"]

        [(and (>= key 265) (<= key 276))
         (format "<f~d>" (- key 264))]

        [else (string (integer->char key))]
    )))))

(define string->keycode
  (lambda (str)
    (let ([is-ctrl #f] [is-alt #f])
      (when (string-starts-with str "C-")
        (set! is-ctrl #t)
        (set! str (substring str 2 (string-length str))))
      (when (string-starts-with str "M-")
        (set! is-alt #t)
        (set! str (substring str 2 (string-length str))))
      (let ([key
             (cond
              [(string=? str "<enter>") 10]
              [(string=? str "<return>") 13]
              [(string=? str "<escape>") 27]
              [(string=? str "<space>") 32]
              [(string=? str "<backspace>") 127]

              [(string=? str "<left>") KEY_LEFT]
              [(string=? str "<right>") KEY_RIGHT]
              [(string=? str "<up>") KEY_UP]
              [(string=? str "<down>") KEY_DOWN]

              [(string=? str "<home>") KEY_HOME]
              [(string=? str "<end>") KEY_END]
              [(string=? str "<insert>") KEY_IC]
              [(string=? str "<delete>") KEY_DC]
              [(string=? str "<prior>") KEY_PPAGE]
              [(string=? str "<next>") KEY_NPAGE]

              [(string=? str "<f1>") 265]
              [(string=? str "<f2>") 266]
              [(string=? str "<f3>") 267]
              [(string=? str "<f4>") 268]
              [(string=? str "<f5>") 269]
              [(string=? str "<f6>") 270]
              [(string=? str "<f7>") 271]
              [(string=? str "<f8>") 272]
              [(string=? str "<f9>") 273]
              [(string=? str "<f10>") 274]
              [(string=? str "<f11>") 275]
              [(string=? str "<f12>") 276]

              [else (char->integer (string-ref str 0))])])
        (+ key
           (if is-ctrl CTRL_MASK 0)
           (if is-alt ALT_MASK 0))))))

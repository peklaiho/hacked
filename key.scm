;; Modifier keys
(define MOD_CTRL (bitwise-arithmetic-shift 1 29))
(define MOD_ALT (bitwise-arithmetic-shift 1 30))
(define MOD_SHIFT (bitwise-arithmetic-shift 1 31))

;; --------------------------------------
;; Parse raw key from terminal to keycode
;; --------------------------------------

(define parse-raw-key
  (lambda (key)
    (let ([bor bitwise-ior])
      (cond
       ;; Tab/Return/Enter
       [(or (= key 9) (= key 10) (= key 13))
        (cons key 0)]
       [(= key 353) (cons 9 MOD_SHIFT)]

       ;; C-a to C-z
       [(and (>= key 1) (<= key 26))
        (cons (+ key 96) MOD_CTRL)]
       ;; C-h
       [(= key 263) (cons 104 MOD_CTRL)]
       ;; C-4 to C-7
       [(and (>= key 28) (<= key 31))
        (cons (+ key 24) MOD_CTRL)]

       ;; Function keys
       [(and (>= key 277) (<= key 288))
        (cons (- key 12) MOD_SHIFT)]
       [(and (>= key 313) (<= key 324))
        (cons (- key 48) MOD_ALT)]
       [(and (>= key 325) (<= key 327))
        (cons (- key 60) (bor MOD_SHIFT MOD_ALT))]
       [(and (>= key 289) (<= key 300))
        (cons (- key 24) MOD_CTRL)]
       [(and (>= key 301) (<= key 312))
        (cons (- key 36) (bor MOD_SHIFT MOD_CTRL))]

       ;; Arrow keys
       [(= key 336) (cons KEY_DOWN MOD_SHIFT)]
       [(= key 524) (cons KEY_DOWN MOD_ALT)]
       [(= key 525) (cons KEY_DOWN (bor MOD_SHIFT MOD_ALT))]
       [(= key 526) (cons KEY_DOWN MOD_CTRL)]
       [(= key 527) (cons KEY_DOWN (bor MOD_SHIFT MOD_CTRL))]
       [(= key 528) (cons KEY_DOWN (bor MOD_ALT MOD_CTRL))]

       [(= key 337) (cons KEY_UP MOD_SHIFT)]
       [(= key 565) (cons KEY_UP MOD_ALT)]
       [(= key 566) (cons KEY_UP (bor MOD_SHIFT MOD_ALT))]
       [(= key 567) (cons KEY_UP MOD_CTRL)]
       [(= key 568) (cons KEY_UP (bor MOD_SHIFT MOD_CTRL))]
       [(= key 569) (cons KEY_UP (bor MOD_ALT MOD_CTRL))]

       [(= key 393) (cons KEY_LEFT MOD_SHIFT)]
       [(= key 544) (cons KEY_LEFT MOD_ALT)]
       [(= key 545) (cons KEY_LEFT (bor MOD_SHIFT MOD_ALT))]
       [(= key 546) (cons KEY_LEFT MOD_CTRL)]
       [(= key 547) (cons KEY_LEFT (bor MOD_SHIFT MOD_CTRL))]
       [(= key 548) (cons KEY_LEFT (bor MOD_ALT MOD_CTRL))]

       [(= key 402) (cons KEY_RIGHT MOD_SHIFT)]
       [(= key 559) (cons KEY_RIGHT MOD_ALT)]
       [(= key 560) (cons KEY_RIGHT (bor MOD_SHIFT MOD_ALT))]
       [(= key 561) (cons KEY_RIGHT MOD_CTRL)]
       [(= key 562) (cons KEY_RIGHT (bor MOD_SHIFT MOD_CTRL))]
       [(= key 563) (cons KEY_RIGHT (bor MOD_ALT MOD_CTRL))]

       ;; Home etc.
       [(= key 391) (cons KEY_HOME MOD_SHIFT)]
       [(= key 534) (cons KEY_HOME MOD_ALT)]
       [(= key 535) (cons KEY_HOME (bor MOD_SHIFT MOD_ALT))]
       [(= key 536) (cons KEY_HOME MOD_CTRL)]
       [(= key 537) (cons KEY_HOME (bor MOD_SHIFT MOD_CTRL))]
       [(= key 538) (cons KEY_HOME (bor MOD_ALT MOD_CTRL))]

       [(= key 383) (cons KEY_DC MOD_SHIFT)]
       [(= key 518) (cons KEY_DC MOD_ALT)]
       [(= key 519) (cons KEY_DC (bor MOD_SHIFT MOD_ALT))]
       [(= key 520) (cons KEY_DC MOD_CTRL)]
       [(= key 521) (cons KEY_DC (bor MOD_SHIFT MOD_CTRL))]
       [(= key 522) (cons KEY_DC (bor MOD_ALT MOD_CTRL))]

       [(= key 396) (cons KEY_NPAGE MOD_SHIFT)]
       [(= key 549) (cons KEY_NPAGE MOD_ALT)]
       [(= key 550) (cons KEY_NPAGE (bor MOD_SHIFT MOD_ALT))]
       [(= key 551) (cons KEY_NPAGE MOD_CTRL)]
       [(= key 552) (cons KEY_NPAGE (bor MOD_SHIFT MOD_CTRL))]
       [(= key 553) (cons KEY_NPAGE (bor MOD_ALT MOD_CTRL))]

       [(= key 398) (cons KEY_PPAGE MOD_SHIFT)]
       [(= key 554) (cons KEY_PPAGE MOD_ALT)]
       [(= key 555) (cons KEY_PPAGE (bor MOD_SHIFT MOD_ALT))]
       [(= key 556) (cons KEY_PPAGE MOD_CTRL)]
       [(= key 557) (cons KEY_PPAGE (bor MOD_SHIFT MOD_CTRL))]
       [(= key 558) (cons KEY_PPAGE (bor MOD_ALT MOD_CTRL))]

       [(= key 386) (cons KEY_END MOD_SHIFT)]
       [(= key 529) (cons KEY_END MOD_ALT)]
       [(= key 530) (cons KEY_END (bor MOD_SHIFT MOD_ALT))]
       [(= key 531) (cons KEY_END MOD_CTRL)]
       [(= key 532) (cons KEY_END (bor MOD_SHIFT MOD_CTRL))]
       [(= key 533) (cons KEY_END (bor MOD_ALT MOD_CTRL))]

       ;; Everything else
       [else (cons key 0)]))))

(define parse-terminal-key
  (lambda (raw-key is-alt)
    (let ([keydata (parse-raw-key raw-key)])
      (let ([keycode (bitwise-ior
                      (car keydata) (cdr keydata)
                      (if is-alt MOD_ALT 0))])
        (debug-log (format "KEY: ~d, Alt: ~d, Code: ~d, String: ~a"
                           raw-key (if is-alt 1 0)
                           keycode (keycode->string keycode)))
        keycode))))

;; ----------------------------
;; Read raw input from keyboard
;; ----------------------------

;; Read a key, returning #f if an exception occurs.
(define try-read-key
  (lambda ()
    (call/cc
     (lambda (err)
       (with-exception-handler
        (lambda (ex) (err #f))
        (lambda () (getch)))))))

;; Read key without delay. Used to read second key after ALT.
(define read-key-nodelay
  (lambda ()
    (nodelay stdscr #t)
    (let ([key (try-read-key)])
      (nodelay stdscr #f)
      key)))

;; Read one key, and if it is ALT, read a second key.
;; Otherwise return the first key.
(define read-full-key
  (lambda ()
    (let ([k1 (getch)])
      (if (not (= k1 27)) (cons k1 #f)
          ;; 27 is either ESC or ALT but we have
          ;; to read second key to find out.
          (let ([k2 (read-key-nodelay)])
            (if k2 (cons k2 #t) (cons k1 #f)))))))

;; Read key and parse it into keycode.
(define read-input
  (lambda ()
    (let ([keydata (read-full-key)])
      (parse-terminal-key (car keydata) (cdr keydata)))))

;; ----------------------------------------
;; Convert keycode to string and vice versa
;; ----------------------------------------

(define keycode-mod?
  (lambda (key mod)
    (not (= (bitwise-and key mod) 0))))

(define keycode-base-value
  (lambda (key)
    (bitwise-and
     (bitwise-not MOD_CTRL)
     (bitwise-not MOD_ALT)
     (bitwise-not MOD_SHIFT)
     key)))

(define keycode->string
  (lambda (keycode)
    (let ([key (keycode-base-value keycode)])
      (format "~a~a~a~a"
       (if (keycode-mod? keycode MOD_CTRL) "C-" "")
       (if (keycode-mod? keycode MOD_ALT) "M-" "")
       (if (keycode-mod? keycode MOD_SHIFT) "S-" "")
       (cond
        [(= key 0) "<null>"]
        [(= key 9) "<tab>"]
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
    (let ([mods 0])
      (when (string-starts-with str "C-")
        (set! mods (bitwise-ior mods MOD_CTRL))
        (set! str (substring str 2 (string-length str))))
      (when (string-starts-with str "M-")
        (set! mods (bitwise-ior mods MOD_ALT))
        (set! str (substring str 2 (string-length str))))
      (when (string-starts-with str "S-")
        (set! mods (bitwise-ior mods MOD_SHIFT))
        (set! str (substring str 2 (string-length str))))
      (let ([key
        (cond
          [(string=? str "<null>") 0]
          [(string=? str "<tab>") 9]
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
        (bitwise-ior key mods)))))

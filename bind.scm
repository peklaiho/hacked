(define make-key-map
  (lambda ()
    (make-hashtable (lambda (a) a) eq?)))

(define global-key-map (make-key-map))

(define global-set-key
  (lambda (keycode fname)
    (debug-log (format "BIND   => ~d ~a :: ~a" keycode (keycode->string keycode) fname))
    (hashtable-set! global-key-map keycode fname)))

(define binding-for-key
  (lambda (keycode)
    (let ([fname (hashtable-ref global-key-map keycode #f)])
      (if fname
          (begin
            (debug-log (format "FOUND  => ~d ~a :: ~s"
                               keycode (keycode->string keycode) fname))
            (eval fname)) #f))))

     ;; Movement
 ;;    [(= key KEY_LEFT)
   ;;   (lambda () (backward-character))]
;;     [(= key KEY_RIGHT)
;;  ;;    (lambda () (forward-character))]
;;     [(= key KEY_UP)
;;      (lambda () (backward-line))]
;;     [(= key KEY_DOWN)
;;      (lambda () (forward-line))]
;;     [(= key KEY_HOME)
;;      (lambda () (begin-of-line))]
;;     [(= key KEY_END)
;;      (lambda () (end-of-line))]

;;     [(= key (char->integer #\<))
;;      (lambda () (begin-of-buffer))]
;;     [(= key (char->integer #\>))
;;      (lambda () (end-of-buffer))]

     ;; Scrolling
;;     [(= key 567)
;;      (lambda () (scroll-up))]
;;     [(= key 526)
;;      (lambda () (scroll-down))]
;;     [(= key 546)
;;      (lambda () (scroll-left))]
;;     [(= key 561)
;;      (lambda () (scroll-right))]

;;     [(= key KEY_PPAGE)
;;      (lambda () (scroll-page-up))]
;;     [(= key KEY_NPAGE)
;;      (lambda () (scroll-page-down))]

;;     [(= key (char->integer #\t))
;;      (lambda () (scroll-current-line-top))]
;;     [(= key (char->integer #\b))
;;      (lambda () (scroll-current-line-bottom))]
;;     [(= key (char->integer #\m))
;;      (lambda () (scroll-current-line-middle))]

     ;; Deletion
;;     [(= key KEY_DC)
;;      (lambda () (delete-character-forward))]
;;     [(or (= key 127))
;;      (lambda () (delete-character-backward))]

;;     [(= key (char->integer #\q))
;;      (lambda () (exit-program 0))]
;;     [else
;;      (lambda () (insert-character-forward (integer->char key)))])))


(define bind-default-keys
  (lambda ()
    (global-set-key (string->keycode "e") 'exit-program)
    (global-set-key (string->keycode "C-q") 'exit-program)

    ;; (global-set-key (string->keycode "+") 'insert-character-forward #\+)
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
      (if (= keycode KEY_RESIZE) (screen-size-changed)
          (let ([f (binding-for-key keycode)])
            (if f (f)
                (debug-log
                 (format "NOBIND => ~d ~a"
                         keycode
                         (keycode->string keycode)))))))))

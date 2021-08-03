;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; hacked - hacker's editor
;; Copyright (c) 2021 Pekka Laiho
;; License: GPLv3
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;; Eval string in exception handler and show result as message.
(define eval-string
  (case-lambda
   [()
    (perform-query
     "M-x "
     ""
     (lambda (text) (eval-string text))
     #f)]
   [(text)
    (show-message
     (call/cc
      (lambda (err)
        (with-exception-handler
         (lambda (ex) (err (format "Error: ~s" ex)))
         (lambda ()
           (format
            "Result: ~s"
            (eval
             (read
              (open-string-input-port text)))))))) #f)]))

(define exit-program-confirm
  (lambda ()
    (if (unsaved-buffers?)
        (perform-confirm
         "Modified buffer, really exit (y/n)? "
         (lambda () (exit-program 0)) #f)
        (exit-program 0))))

(define exit-program
  (lambda (exit-code)
    (endwin)
    (exit exit-code)))

(define min-max
  (lambda (value minimum maximum)
    (min (max value minimum) maximum)))

;; Generate list of integers from i to j (inclusive)
(define range
  (lambda (i j)
    (map (lambda (n) (+ i n)) (iota (add1 (- j i))))))

;; Repeat function n times
(define repeat-times
  (lambda (f n)
    (cond
     [(<= n 0) #f]
     [(= n 1) (f)]
     [else (f)
           (repeat-times f (sub1 n))])))

(define vector-index-of
  (lambda (v a)
    (let loop ([i 0])
      (if (= (vector-length v) i) #f
          (if (eq? (vector-ref v i) a) i
              (loop (add1 i)))))))

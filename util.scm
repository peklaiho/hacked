;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; hacked - hacker's editor
;; Copyright (c) 2021 Pekka Laiho
;; License: GPLv3
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(define exit-program
  (case-lambda
   [() (exit-program 0)]
   [(exit-code)
    (endwin)
    (exit exit-code)]))

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

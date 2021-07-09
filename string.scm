;; Find the first occurence of character from string.
;; Returns the index of the character or #f if not found.
;; Start is the index to search from.
(define string-find-first
  (lambda (str ch start)
    (call/cc
     (lambda (break)
       (let loop ([i start] [len (string-length str)])
         (cond
          [(>= i len) (break #f)]
          [(equal? (string-ref str i) ch) (break i)]
          [else (loop (add1 i) len)]))))))

;; Find the last occurence of character from string.
;; Returns the index of the character or #f if not found.
;; Start is the index to search from.
(define string-find-last
  (lambda (str ch start)
    (call/cc
     (lambda (break)
       (let loop ([i start])
         (cond
          [(< i 0) (break #f)]
          [(equal? (string-ref str i) ch) (break i)]
          [else (loop (sub1 i))]))))))

;; Split string by character and return the substrings as a list.
(define string-split
  (lambda (str ch)
    (map (lambda (p) (substring str (car p) (cdr p)))
         (string-split-index str ch))))

;; Split string by character and return the indexes
;; of the substrings as pairs.
(define string-split-index
  (lambda (str ch)
    (let loop ([start (string-find-last str ch (sub1 (string-length str)))]
               [end (string-length str)]
               [results '()])
      (if (not start) (cons (cons 0 end) results)
          (loop (string-find-last str ch (sub1 start)) start
                (cons (cons (add1 start) end) results))))))

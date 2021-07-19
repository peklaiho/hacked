(define char-alphanumeric?
  (lambda (ch)
    (or (char-alphabetic? ch)
        (char-numeric? ch))))

(define char-punctuation?
  (lambda (ch)
    (or (char=? ch #\.)
        (char=? ch #\!)
        (char=? ch #\?))))

(define word-boundary
  (list (lambda (a) (char-alphanumeric? a))
        (lambda (a) (not (char-alphanumeric? a)))))

(define sentence-boundary
  (list (lambda (a) (char-punctuation? a))
        (lambda (a) (not (char-punctuation? a)))))

;; Find first occurence of character that matches predicate p.
(define string-find-char-forward-p
  (lambda (str p start)
    (call/cc
     (lambda (break)
       (let loop ([i start] [len (string-length str)])
         (cond
          [(>= i len) (break #f)]
          [(p (string-ref str i)) (break i)]
          [else (loop (add1 i) len)]))))))

;; Find last occurence of character that matches predicate p.
(define string-find-char-backward-p
  (lambda (str p start)
    (call/cc
     (lambda (break)
       (let loop ([i start])
         (cond
          [(< i 0) (break #f)]
          [(p (string-ref str i)) (break i)]
          [else (loop (sub1 i))]))))))

;; Find the first occurence of character from string.
;; Returns the index of the character or #f if not found.
;; Start is the index to search from.
(define string-find-char-forward
  (lambda (str ch start)
    (string-find-char-forward-p
     str (lambda (a) (char=? ch a)) start)))

;; Find the last occurence of character from string.
;; Returns the index of the character or #f if not found.
;; Start is the index to search from.
(define string-find-char-backward
  (lambda (str ch start)
    (string-find-char-backward-p
     str (lambda (a) (char=? ch a)) start)))

;; Match predicates in order to each character.
(define string-match-char-sequence
  (lambda (str preds idx idx-fn)
    (cond
     [(null? preds) #t]
     [(or (< idx 0) (>= idx (string-length str))) #f]
     [((car preds) (string-ref str idx))
      (string-match-char-sequence str (cdr preds) (idx-fn idx) idx-fn)]
     [else #f])))

(define string-find-char-sequence
  (lambda (str preds start fw)
    (let ([fn (if fw add1 sub1)])
      (let loop ([i start])
       (cond
        [(or (< i 0) (>= i (string-length str))) #f]
        [(string-match-char-sequence str preds i fn) i]
        [else (loop (fn i))])))))

;; Split string by character and return the substrings as a list.
(define string-split
  (lambda (str ch)
    (map (lambda (p) (substring str (car p) (cdr p)))
         (string-split-index str ch))))

;; Split string by character and return the indexes
;; of the substrings as pairs.
(define string-split-index
  (lambda (str ch)
    (let loop ([start (string-find-char-backward str ch (sub1 (string-length str)))]
               [end (string-length str)]
               [results '()])
      (if (not start) (cons (cons 0 end) results)
          (loop (string-find-char-backward str ch (sub1 start)) start
                (cons (cons (add1 start) end) results))))))

(define string-starts-with?
  (lambda (str start)
    (if (< (string-length str) (string-length start)) #f
        (string=? (substring str 0 (string-length start)) start))))

(define string-ends-with?
  (lambda (str end)
    (if (> (string-length end) (string-length str)) #f
        (string=? (substring str
                   (- (string-length str) (string-length end))
                   (string-length str)) end))))

(define string-truncate
  (lambda (str n)
    (if (<= (string-length str) n) str
        (substring str 0 n))))

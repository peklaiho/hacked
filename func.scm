;; Advance point by n characters.
;; Negative value to go backwards.
;; Return #t if changed, otherwise #f.
(define advance-point
  (lambda (n)
    (let ([old (buffer-point)])
      (buffer-point-set! (+ old n))
      (not (= old (buffer-point))))))

;; Editing functions

(define delete-character
  (lambda (idx)
    (if (or (< idx 0) (>= idx (buffer-length))) #f
        (begin
          (buffer-content-set!
           (string-append
            (buffer-substring 0 idx)
            (buffer-substring (add1 idx) (buffer-length))))
          #t))))

(define delete-character-forward
  (lambda ()
    (delete-character (buffer-point))))

(define delete-character-backward
  (lambda ()
    (if (advance-point -1) (delete-character-forward) #f)))

(define insert-character
  (case-lambda
   [(ch) (insert-character ch (buffer-point))]
   [(ch idx) (insert-string (string ch) idx)]))

(define insert-character-adv-point
  (lambda (ch)
    (insert-character ch)
    (advance-point 1)))

(define insert-string
  (case-lambda
   [(txt) (insert-string txt (buffer-point))]
   [(txt idx)
    (buffer-content-set!
     (string-append
      (buffer-substring 0 idx) txt
      (buffer-substring idx (buffer-length))))
    #t]))

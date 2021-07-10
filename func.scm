;; --------
;; Movement
;; --------

;; Advance point by n characters.
;; Negative value to go backwards.
;; Returns #f if failed, otherwise new point.
(define advance-point
  (lambda (n)
    (let ([pt (+ (buffer-point) n)])
      (if (or (< pt 0) (> pt (buffer-length))) #f
          (begin
            (buffer-point-set! pt)
            (buffer-goal-column-set! (buffer-column))
            pt)))))

;; Move point forward one character.
(define forward-character
  (case-lambda
   [() (forward-character 1)]
   [(n) (advance-point n)]))

;; Move point backward one character.
(define backward-character
  (case-lambda
   [() (backward-character 1)]
   [(n) (advance-point (- n))]))

;; Move point to beginning of line.
(define begin-of-line
  (lambda ()
    (let ([pt (car (buffer-line-index))])
      (buffer-point-set! pt)
      (buffer-goal-column-set! (buffer-column))
      pt)))

;; Move point to end of line.
(define end-of-line
  (lambda ()
    (let ([pt (cdr (buffer-line-index))])
      (buffer-point-set! pt)
      (buffer-goal-column-set! (buffer-column))
      pt)))

;; Move point to given line.
;; Column can be given as second argument. It defaults
;; to goal-column of the buffer.
;; Returns the index-pair of the line or #f if not successful.
(define goto-line
  (case-lambda
   [(l) (goto-line l (buffer-goal-column))]
   [(l c)
    (let ([idx (buffer-line-index current-buffer l)])
      (if (not idx) #f
          (begin
            (buffer-point-set! (car idx))
            (buffer-column-set! c)
            idx)))]))

;; Move point to next line.
(define forward-line
  (case-lambda
   [() (forward-line 1)]
   [(n) (goto-line (+ (buffer-line) n))]))

;; Move point to previous line.
(define backward-line
  (case-lambda
   [() (backward-line 1)]
   [(n) (goto-line (- (buffer-line) n))]))

;; --------
;; Deletion
;; --------

;; Delete one character at given index.
;; Does not check bounds, returns #t.
(define delete-character
  (lambda (idx)
    (buffer-content-set!
     (string-append
      (buffer-substring 0 idx)
      (buffer-substring (add1 idx) (buffer-length))))
    #t))

;; Delete one character forward.
(define delete-character-forward
  (lambda ()
    (if (< (buffer-point) (buffer-length))
        (delete-character (buffer-point))
        #f)))

;; Delete one character backward.
(define delete-character-backward
  (lambda ()
    (if (backward-character)
        (delete-character-forward)
        #f)))

;; ---------
;; Insertion
;; ---------

;; Insert character.
(define insert-character
  (case-lambda
   [(ch) (insert-character ch (buffer-point))]
   [(ch idx) (insert-string (string ch) idx)]))

;; Insert character and move point forward.
(define insert-character-forward
  (lambda (ch)
    (insert-character ch)
    (forward-character)))

;; Insert string.
(define insert-string
  (case-lambda
   [(txt) (insert-string txt (buffer-point))]
   [(txt idx)
    (buffer-content-set!
     (string-append
      (buffer-substring 0 idx) txt
      (buffer-substring idx (buffer-length))))
    #t]))

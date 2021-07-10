;; Movement functions

;; Advance point by n characters.
;; Negative value to go backwards.
;; Returns #f if failed, otherwise new point.
(define advance-point
  (lambda (n)
    (let ([goal (+ (buffer-point) n)])
      (if (or (< goal 0) (> goal (buffer-length))) #f
          (begin
            (buffer-point-set! goal)
            (buffer-goal-column-set! (buffer-column))
            (buffer-point))))))

(define forward-character
  (case-lambda
   [() (forward-character 1)]
   [(n) (advance-point n)]))

(define backward-character
  (case-lambda
   [() (backward-character 1)]
   [(n) (advance-point (- n))]))

(define goto-line
  (lambda (l)
    (let ([idx (buffer-line-index current-buffer l)])
      (if (not idx) #f
          (begin
            (buffer-point-set! (car idx))
            (buffer-column-set! (buffer-goal-column)))))))

(define forward-line
  (case-lambda
   [() (forward-line 1)]
   [(n) (goto-line (+ (buffer-line) n))]))

(define backward-line
  (case-lambda
   [() (backward-line 1)]
   [(n) (goto-line (- (buffer-line) n))]))

;; Editing functions

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

;; Insert one character.
(define insert-character
  (case-lambda
   [(ch) (insert-character ch (buffer-point))]
   [(ch idx) (insert-string (string ch) idx)]))

;; Insert character and move forward.
(define insert-character-forward
  (lambda (ch)
    (insert-character ch)
    (forward-character)))

;; Insert string and return #t.
(define insert-string
  (case-lambda
   [(txt) (insert-string txt (buffer-point))]
   [(txt idx)
    (buffer-content-set!
     (string-append
      (buffer-substring 0 idx) txt
      (buffer-substring idx (buffer-length))))
    #t]))

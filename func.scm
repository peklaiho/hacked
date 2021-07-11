;; ----
;; Misc
;; ----

(define screen-size-changed
  (lambda ()
    (set! redraw-screen #t)
    (reconcile-by-scrolling)))

;; --------
;; Movement
;; --------

;; Helper function for setting point.
(define set-point
  (lambda (pt)
    (if (or (< pt 0) (> pt (buffer-length))) #f
        (begin
          (buffer-point-set! pt)
          (reconcile-by-scrolling)
          #t))))

;; Set point and also set goal-column.
(define set-point-and-goal
  (lambda (pt)
    (let ([result (set-point pt)])
      (when result
        (buffer-goal-column-set! (buffer-column)))
      result)))

;; Move point forward one character.
(define forward-character
  (case-lambda
   [() (forward-character 1)]
   [(n) (set-point-and-goal (+ (buffer-point) n))]))

;; Move point backward one character.
(define backward-character
  (case-lambda
   [() (backward-character 1)]
   [(n) (set-point-and-goal (- (buffer-point) n))]))

;; Move point to beginning of line.
(define begin-of-line
  (lambda ()
    (let ([line (buffer-line-index)])
      (set-point-and-goal (car line)))))

;; Move point to end of line.
(define end-of-line
  (lambda ()
    (let ([line (buffer-line-index)])
      (set-point-and-goal (cdr line)))))

;; Move to beginning of buffer.
(define begin-of-buffer
  (lambda ()
    (set-point-and-goal 0)))

;; Move to end of buffer.
(define end-of-buffer
  (lambda ()
    (set-point-and-goal (buffer-length))))

;; Move point to given line and try to move
;; column to goal-column.
(define goto-line
  (lambda (l)
    (let ([idx (buffer-line-index l)])
      (when idx
        (set-point
         (min-max (+ (car idx) (buffer-goal-column))
                  (car idx)
                  (cdr idx))))
      idx)))

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

;; ------------------
;; Scrolling (offset)
;; ------------------

(define advance-offset
  (lambda (n)
    (buffer-offset-set! (+ (buffer-offset) n))
    (reconcile-by-moving-point)))

(define scroll-line-forward
  (lambda ()
    (advance-offset 1)))

(define scroll-line-backward
  (lambda ()
    (advance-offset -1)))

(define scroll-page-forward
  (lambda ()
    (advance-offset (scroll-page-amount))))

(define scroll-page-backward
  (lambda ()
    (advance-offset (- (scroll-page-amount)))))

(define scroll-page-amount
  (lambda ()
    (- LINES 4)))

;; --------
;; Deletion
;; --------

;; Delete one character at given index.
(define delete-character
  (lambda (idx)
    (if (or (< idx 0) (>= idx (buffer-length))) #f
        (begin
          (buffer-content-set!
           (string-append
            (buffer-substring 0 idx)
            (buffer-substring (add1 idx) (buffer-length))))
          #t))))

;; Delete one character forward.
(define delete-character-forward
  (lambda ()
    (let ([result (delete-character (buffer-point))])
      result)))

;; Delete one character backward.
(define delete-character-backward
  (lambda ()
    (let ([result (delete-character (sub1 (buffer-point)))])
      (when result
        (backward-character))
      result)))

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
    (let ([result (insert-character ch)])
      (when result
        (forward-character))
      result)))

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

;; ---------
;; Reconcile
;; ---------

;; Reconcile point and offset so that point
;; is always on a visible line. We can reconcile
;; either by moving point or offset.

;; Move the point to a visible line.
(define reconcile-by-moving-point
  (lambda ()
    (debug-log "reconcile-by-moving-point")))

;; Scroll the offset to the point.
(define reconcile-by-scrolling
  (lambda ()
    (debug-log "reconcile-by-scrolling")))

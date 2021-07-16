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

;; Move point to end of next word.
(define forward-word
  (case-lambda
   [() (forward-word 1)]
   [(n) (let ([i (buffer-find-char-seq word-boundary #t)])
          (if i (set-point-and-goal (add1 i))
              (end-of-buffer)))]))

;; Move point to beginning of previous word.
(define backward-word
  (case-lambda
   [() (backward-word 1)]
   [(n) (let ([i (buffer-find-char-seq word-boundary #f)])
          (if i (set-point-and-goal i)
              (begin-of-buffer)))]))

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

;; -------------------
;; Scrolling (offsets)
;; -------------------

(define set-offset-line
  (lambda (n)
    (buffer-offset-line-set! n)
    (reconcile-by-moving-point)))

(define set-offset-column
  (lambda (n)
    (buffer-offset-column-set! n)
    (reconcile-by-moving-point)))

(define scroll-up
  (case-lambda
   [() (scroll-up 1)]
   [(n) (set-offset-line (- (buffer-offset-line) n))]))

(define scroll-down
  (case-lambda
   [() (scroll-down 1)]
   [(n) (set-offset-line (+ (buffer-offset-line) n))]))

(define scroll-left
  (case-lambda
   [() (scroll-left 1)]
   [(n) (set-offset-column (- (buffer-offset-column) n))]))

(define scroll-right
  (case-lambda
   [() (scroll-right 1)]
   [(n) (set-offset-column (+ (buffer-offset-column) n))]))

(define scroll-page-up
  (lambda ()
    (scroll-up (scroll-page-amount))))

(define scroll-page-down
  (lambda ()
    (scroll-down (scroll-page-amount))))

(define scroll-page-amount
  (lambda ()
    (- (lines-for-buffer) 2)))

(define scroll-current-line-top
  (lambda ()
    (set-offset-line (buffer-line))))

(define scroll-current-line-bottom
  (lambda ()
    (set-offset-line (- (buffer-line) (lines-for-buffer) -1))))

(define scroll-current-line-middle
  (lambda ()
    (set-offset-line (- (buffer-line) (div (lines-for-buffer) 2)))))

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
    (let* ([pt-before (buffer-point)]
           [result (delete-character (sub1 (buffer-point)))])
      ;; Move back only if point is same as before
      ;; (was not moved already by the delete operation).
      (when (and result (= pt-before (buffer-point)))
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
;; is always visible. We can reconcile
;; either by moving point or offset.

;; Move the point to current offsets.
(define reconcile-by-moving-point
  (lambda ()
    (let ([ln (buffer-line)]
          [cl (buffer-column)]
          [ofs-ln (buffer-offset-line)]
          [ofs-cl (buffer-offset-column)])
      (when (< ln ofs-ln)
        (goto-line ofs-ln))
      (when (> ln (+ ofs-ln (last-buffer-line)))
        (goto-line (+ ofs-ln (last-buffer-line))))
      (when (< cl ofs-cl)
        (set-point-and-goal (+ (buffer-point) (- ofs-cl cl))))
      (when (> cl (+ ofs-cl (last-buffer-column)))
        (set-point-and-goal (- (buffer-point)
                               (- cl (+ ofs-cl (last-buffer-column)))))))))

;; Change offsets so point is visible.
(define reconcile-by-scrolling
  (lambda ()
    (let ([ln (buffer-line)]
          [cl (buffer-column)]
          [ofs-ln (buffer-offset-line)]
          [ofs-cl (buffer-offset-column)])
      (when (< ln ofs-ln)
        (buffer-offset-line-set! ln))
      (when (> ln (+ ofs-ln (last-buffer-line)))
        (buffer-offset-line-set! (- ln (last-buffer-line))))
      (when (< cl ofs-cl)
        (buffer-offset-column-set! cl))
      (when (> cl (+ ofs-cl (last-buffer-column)))
        (buffer-offset-column-set! (- cl (last-buffer-column)))))))

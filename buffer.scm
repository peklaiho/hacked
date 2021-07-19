(define current-buffer #f)

(define buffer-list (list))

(define buffer-rtd
  (make-record-type-descriptor
   'buffer #f #f #f #f
   '#((mutable name)
      (mutable filename)
      (mutable content)
      (mutable point)
      (mutable goal-col)
      (mutable offset-line)
      (mutable offset-col)
      (mutable line)
      (mutable line-indices)
      (mutable modified)
      (mutable newline-char))))

(define buffer-rcd
  (make-record-constructor-descriptor
   buffer-rtd #f #f))

;; Constructor
(define make-buffer
  (case-lambda
   [(name) (make-buffer name "" #f)]
   [(name content filename)
    (let ([b ((record-constructor buffer-rcd)
              name
              filename
              content
              0          ; point
              0          ; goal-col
              0          ; offset-line
              0          ; offset-col
              0          ; line
              '#()       ; line-indices
              #f         ; modified
              #\newline  ; newline-char
              )])
      (buffer-update-line-indices b)
      (set! buffer-list (cons b buffer-list))
      (set! current-buffer b)
      b)]))

;; Internal functions

;; Find the current line where the point is on.
;; Start the search from offset-line because we
;; are likely to be near that always.
(define buffer-update-line
  (lambda (b)
    (buffer-line-set! b
      (call/cc
       (lambda (break)
         (let loop ([l (buffer-offset-line b)])
           (let ([idx (vector-ref (buffer-line-indices b) l)]
                 [pt (buffer-point b)])
             (when (< pt (car idx)) (loop (sub1 l)))
             (when (> pt (cdr idx)) (loop (add1 l)))
             (break l))))))))

(define buffer-update-line-indices
  (lambda (b)
    (buffer-line-indices-set! b
     (list->vector
      (string-split-index (buffer-content b) (buffer-newline-char b))))))

;; Getters

(define buffer-name
  (case-lambda
   [() (buffer-name current-buffer)]
   [(b) ((record-accessor buffer-rtd 0) b)]))

(define buffer-filename
  (case-lambda
   [() (buffer-filename current-buffer)]
   [(b) ((record-accessor buffer-rtd 1) b)]))

(define buffer-content
  (case-lambda
   [() (buffer-content current-buffer)]
   [(b) ((record-accessor buffer-rtd 2) b)]))

(define buffer-point
  (case-lambda
   [() (buffer-point current-buffer)]
   [(b) ((record-accessor buffer-rtd 3) b)]))

(define buffer-goal-column
  (case-lambda
   [() (buffer-goal-column current-buffer)]
   [(b) ((record-accessor buffer-rtd 4) b)]))

(define buffer-offset-line
  (case-lambda
   [() (buffer-offset-line current-buffer)]
   [(b) ((record-accessor buffer-rtd 5) b)]))

(define buffer-offset-column
  (case-lambda
   [() (buffer-offset-column current-buffer)]
   [(b) ((record-accessor buffer-rtd 6) b)]))

(define buffer-line
  (case-lambda
   [() (buffer-line current-buffer)]
   [(b) ((record-accessor buffer-rtd 7) b)]))

(define buffer-line-indices
  (case-lambda
   [() (buffer-line-indices current-buffer)]
   [(b) ((record-accessor buffer-rtd 8) b)]))

(define buffer-modified
  (case-lambda
   [() (buffer-modified current-buffer)]
   [(b) ((record-accessor buffer-rtd 9) b)]))

(define buffer-newline-char
  (case-lambda
   [() (buffer-newline-char current-buffer)]
   [(b) ((record-accessor buffer-rtd 10) b)]))

;; Setters

(define buffer-name-set!
  (case-lambda
   [(v) (buffer-name-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 0) b v)]))

(define buffer-filename-set!
  (case-lambda
   [(v) (buffer-filename-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 1) b v)]))

(define buffer-content-set!
  (case-lambda
   [(v) (buffer-content-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 2) b v)
    (buffer-update-line-indices b)
    ;; Check point is inside bounds and call
    ;; buffer-update-line also.
    (buffer-point-set! b (buffer-point b))]))

(define buffer-point-set!
  (case-lambda
   [(v) (buffer-point-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 3) b
           (min-max v 0 (buffer-length b)))
    (buffer-update-line b)]))

(define buffer-goal-column-set!
  (case-lambda
   [(v) (buffer-goal-column-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 4) b v)]))

(define buffer-offset-line-set!
  (case-lambda
   [(v) (buffer-offset-line-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 5) b
           (min-max v 0 (sub1 (vector-length (buffer-line-indices b)))))]))

(define buffer-offset-column-set!
  (case-lambda
   [(v) (buffer-offset-column-set! current-buffer v)]
   [(b v) (let* ([idx (buffer-line-index b (buffer-line b))]
                 [max (- (cdr idx) (car idx))])
            ((record-mutator buffer-rtd 6) b (min-max v 0 max)))]))

(define buffer-line-set!
  (case-lambda
   [(v) (buffer-line-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 7) b v)]))

(define buffer-line-indices-set!
  (case-lambda
   [(v) (buffer-line-indices-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 8) b v)]))

(define buffer-modified-set!
  (case-lambda
   [(v) (buffer-modified-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 9) b v)]))

(define buffer-newline-char-set!
  (case-lambda
   [(v) (buffer-newline-char-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 10) b v)]))

;; Helpers

;; Return the current column index.
(define buffer-column
  (case-lambda
   [() (buffer-column current-buffer)]
   [(b) (- (buffer-point b) (car (buffer-line-index b (buffer-line b))))]))

(define buffer-length
  (case-lambda
   [() (buffer-length current-buffer)]
   [(b) (string-length (buffer-content b))]))

;; Start (inclusive) and end (exclusive) index of given line.
(define buffer-line-index
  (case-lambda
   [() (buffer-line-index current-buffer (buffer-line current-buffer))]
   [(i) (buffer-line-index current-buffer i)]
   [(b i) (let ([ind (buffer-line-indices b)])
            (if (or (< i 0) (>= i (vector-length ind))) #f
                (vector-ref ind i)))]))

(define buffer-paragraph-boundary
  (case-lambda
   [() (buffer-paragraph-boundary current-buffer)]
   [(b) (list
         (lambda (a) (char=? a (buffer-newline-char b)))
         (lambda (a) (char=? a (buffer-newline-char b))))]))

(define buffer-substring
  (case-lambda
   [(beg end) (buffer-substring current-buffer beg end)]
   [(b beg end) (substring (buffer-content b) beg end)]))

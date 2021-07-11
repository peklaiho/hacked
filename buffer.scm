(define current-buffer #f)

(define buffer-rtd
  (make-record-type-descriptor
   'buffer #f #f #f #f
   '#((mutable name)
      (mutable content)
      (mutable point)
      (mutable goal-col)
      (mutable offset)
      (mutable line-indices))))

(define buffer-rcd
  (make-record-constructor-descriptor
   buffer-rtd #f #f))

;; Constructor
(define make-buffer
  (case-lambda
   [(n) (make-buffer n "")]
   [(n c)
    (let ([b ((record-constructor buffer-rcd) n c 0 0 0 '#())])
      (buffer-update-line-indices b)
      b)]))

;; Getters

(define buffer-name
  (case-lambda
   [() (buffer-name current-buffer)]
   [(b) ((record-accessor buffer-rtd 0) b)]))

(define buffer-content
  (case-lambda
   [() (buffer-content current-buffer)]
   [(b) ((record-accessor buffer-rtd 1) b)]))

(define buffer-point
  (case-lambda
   [() (buffer-point current-buffer)]
   [(b) ((record-accessor buffer-rtd 2) b)]))

(define buffer-goal-column
  (case-lambda
   [() (buffer-goal-column current-buffer)]
   [(b) ((record-accessor buffer-rtd 3) b)]))

(define buffer-offset
  (case-lambda
   [() (buffer-offset current-buffer)]
   [(b) ((record-accessor buffer-rtd 4) b)]))

(define buffer-line-indices
  (case-lambda
   [() (buffer-line-indices current-buffer)]
   [(b) ((record-accessor buffer-rtd 5) b)]))

;; Helpers

(define buffer-length
  (case-lambda
   [() (buffer-length current-buffer)]
   [(b) (string-length (buffer-content b))]))

;; Return the current column index.
(define buffer-column
  (case-lambda
   [() (buffer-column current-buffer)]
   [(b) (- (buffer-point b) (car (buffer-line-index b)))]))

;; Return the current line index.
(define buffer-line
  (case-lambda
   [() (buffer-line current-buffer)]
   [(b) (call/cc
         (lambda (break)
           (let loop ([l 0])
             (if (<= (buffer-point b)
                     (cdr (vector-ref (buffer-line-indices b) l)))
                 (break l)
                 (loop (add1 l))))))]))

;; Start (inclusive) and end (exclusive) index of given line.
(define buffer-line-index
  (case-lambda
   [() (buffer-line-index current-buffer)]
   [(b) (buffer-line-index b (buffer-line b))]
   [(b i) (let ([ind (buffer-line-indices b)])
            (if (or (< i 0) (>= i (vector-length ind))) #f
                (vector-ref ind i)))]))

;; Indexes of the previous line or #f.
(define buffer-line-index-prev
  (case-lambda
   [() (buffer-line-index-prev current-buffer)]
   [(b) (buffer-line-index b (sub1 (buffer-line b)))]))

;; Indexes of the next line or #f.
(define buffer-line-index-next
  (case-lambda
   [() (buffer-line-index-next current-buffer)]
   [(b) (buffer-line-index b (add1 (buffer-line b)))]))

(define buffer-substring
  (case-lambda
   [(beg end) (buffer-substring current-buffer beg end)]
   [(b beg end) (substring (buffer-content b) beg end)]))

(define buffer-update-line-indices
  (lambda (b)
    (buffer-line-indices-set! b
     (list->vector
      (string-split-index (buffer-content b) #\newline)))))

;; Setters

(define buffer-name-set!
  (case-lambda
   [(v) (buffer-name-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 0) b v)]))

(define buffer-content-set!
  (case-lambda
   [(v) (buffer-content-set! current-buffer v)]
   [(b v)
    ((record-mutator buffer-rtd 1) b v)
    (buffer-update-line-indices b)]))

(define buffer-point-set!
  (case-lambda
   [(v) (buffer-point-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 2) b
           (min-max v 0 (buffer-length b)))]))

(define buffer-goal-column-set!
  (case-lambda
   [(v) (buffer-goal-column-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 3) b v)]))

(define buffer-offset-set!
  (case-lambda
   [(v) (buffer-offset-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 4) b
           (min-max v 0 (- (vector-length (buffer-line-indices b)) 6)))]))

(define buffer-line-indices-set!
  (case-lambda
   [(v) (buffer-line-indices-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 5) b v)]))

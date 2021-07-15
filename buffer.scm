(define current-buffer #f)

(define buffer-rtd
  (make-record-type-descriptor
   'buffer #f #f #f #f
   '#((mutable name)
      (mutable content)
      (mutable point)
      (mutable goal-col)
      (mutable offset-line)
      (mutable offset-col)
      (mutable line)
      (mutable line-indices))))

(define buffer-rcd
  (make-record-constructor-descriptor
   buffer-rtd #f #f))

;; Constructor
(define make-buffer
  (case-lambda
   [(name) (make-buffer name "")]
   [(name content)
    (let ([b ((record-constructor buffer-rcd)
              name
              content
              0        ; point
              0        ; goal-col
              0        ; offset-line
              0        ; offset-col
              0        ; line
              '#()     ; line-indices
              )])
      (buffer-update-line-indices b)
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
      (string-split-index (buffer-content b) #\newline)))))

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

(define buffer-offset-line
  (case-lambda
   [() (buffer-offset-line current-buffer)]
   [(b) ((record-accessor buffer-rtd 4) b)]))

(define buffer-offset-column
  (case-lambda
   [() (buffer-offset-column current-buffer)]
   [(b) ((record-accessor buffer-rtd 5) b)]))

(define buffer-line
  (case-lambda
   [() (buffer-line current-buffer)]
   [(b) ((record-accessor buffer-rtd 6) b)]))

(define buffer-line-indices
  (case-lambda
   [() (buffer-line-indices current-buffer)]
   [(b) ((record-accessor buffer-rtd 7) b)]))

;; Setters

(define buffer-name-set!
  (case-lambda
   [(v) (buffer-name-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 0) b v)]))

(define buffer-content-set!
  (case-lambda
   [(v) (buffer-content-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 1) b v)
    (buffer-update-line-indices b)
    (buffer-update-line b)]))

(define buffer-point-set!
  (case-lambda
   [(v) (buffer-point-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 2) b
           (min-max v 0 (buffer-length b)))
    (buffer-update-line b)]))

(define buffer-goal-column-set!
  (case-lambda
   [(v) (buffer-goal-column-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 3) b v)]))

(define buffer-offset-line-set!
  (case-lambda
   [(v) (buffer-offset-line-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 4) b
           (min-max v 0 (sub1 (vector-length (buffer-line-indices b)))))]))

(define buffer-offset-column-set!
  (case-lambda
   [(v) (buffer-offset-column-set! current-buffer v)]
   [(b v) (let* ([idx (buffer-line-index b (buffer-line b))]
                 [max (- (cdr idx) (car idx))])
            ((record-mutator buffer-rtd 5) b (min-max v 0 max)))]))

(define buffer-line-set!
  (case-lambda
   [(v) (buffer-line-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 6) b v)]))

(define buffer-line-indices-set!
  (case-lambda
   [(v) (buffer-line-indices-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 7) b v)]))

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

;; Indexes of the previous line or #f.
(define buffer-line-index-prev
  (case-lambda
   [() (buffer-line-index-prev current-buffer)]
   [(b) (buffer-line-index (sub1 (buffer-line b)) b)]))

;; Indexes of the next line or #f.
(define buffer-line-index-next
  (case-lambda
   [() (buffer-line-index-next current-buffer)]
   [(b) (buffer-line-index (add1 (buffer-line b)) b)]))

;; Find a sequence of characters that satisfy
;; the given predicates in order.
(define buffer-find-char-seq
  (case-lambda
   [(preds fw) (buffer-find-char-seq current-buffer preds fw)]
   [(b preds fw)
    (let ([fn (if fw add1 sub1)])
      (let loop ([i (fn (buffer-point b))])
       (cond
        [(or (< i 0) (>= i (buffer-length b))) #f]
        [(string-find-char-sequence
          (buffer-content b) preds i fn) i]
        [else (loop (fn i))])))]))

(define buffer-substring
  (case-lambda
   [(beg end) (buffer-substring current-buffer beg end)]
   [(b beg end) (substring (buffer-content b) beg end)]))

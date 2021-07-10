(define current-buffer #f)

(define buffer-rtd
  (make-record-type-descriptor
   'buffer #f #f #f #f
   '#((mutable name)
      (mutable content)
      (mutable point)
      (mutable line-index))))

(define buffer-rcd
  (make-record-constructor-descriptor
   buffer-rtd #f #f))

;; Constructor
(define make-buffer
  (case-lambda
   [(n) (make-buffer n "")]
   [(n c)
    (let ([b ((record-constructor buffer-rcd) n c 0 '#())])
      (buffer-update-line-index b)
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

(define buffer-line-index
  (case-lambda
   [() (buffer-line-index current-buffer)]
   [(b) ((record-accessor buffer-rtd 3) b)]))

;; Helpers

(define buffer-length
  (case-lambda
   [() (buffer-length current-buffer)]
   [(b) (string-length (buffer-content b))]))

(define buffer-substring
  (case-lambda
   [(beg end) (buffer-substring current-buffer beg end)]
   [(b beg end) (substring (buffer-content b) beg end)]))

(define buffer-update-line-index
  (lambda (b)
    (buffer-line-index-set! b
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
    (buffer-update-line-index b)]))

(define buffer-point-set!
  (case-lambda
   [(v) (buffer-point-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 2) b
           (min-max v 0 (buffer-length b)))]))

(define buffer-line-index-set!
  (case-lambda
   [(v) (buffer-line-index-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 3) b v)]))

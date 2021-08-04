;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; hacked - hacker's editor
;; Copyright (c) 2021 Pekka Laiho
;; License: GPLv3
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(define current-buffer #f)

(define buffer-list (list))

(define buffer-rtd
  (make-record-type-descriptor
   'buffer #f #f #f #f
   '#((mutable name)
      (mutable filename)
      (mutable content)
      (mutable point)
      (mutable mark)
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
              0          ; mark
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
      b)]))

(define find-buffer
  (lambda (name)
    (let loop ([buffers buffer-list])
      (cond
       [(null? buffers) #f]
       [(string=? name (buffer-name (car buffers))) (car buffers)]
       [else (loop (cdr buffers))]))))

(define find-or-make-buffer
  (lambda (name)
    (let ([buf (find-buffer name)])
      (if buf buf (make-buffer name)))))

;; Get the previous buffer to current-buffer.
(define previous-buffer
  (lambda ()
    (if (= (length buffer-list) 1) #f
        (let* ([bufs (list->vector buffer-list)]
               [idx (vector-index-of bufs current-buffer)])
          (if (= idx (sub1 (vector-length bufs)))
              (vector-ref bufs 0)
              (vector-ref bufs (add1 idx)))))))

;; Get the next buffer to current-buffer.
(define next-buffer
  (lambda ()
    (if (= (length buffer-list) 1) #f
        (let* ([bufs (list->vector buffer-list)]
               [idx (vector-index-of bufs current-buffer)])
          (if (= idx 0)
              (vector-ref bufs (sub1 (vector-length bufs)))
              (vector-ref bufs (sub1 idx)))))))

;; Return true if there are modified and non-temporary buffers.
(define unsaved-buffers?
  (lambda ()
    (let loop ([list buffer-list])
      (if (null? list) #f
          (if (and (buffer-modified (car list)) (not (buffer-temporary? (car list)))) #t
              (loop (cdr list)))))))

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

(define buffer-mark
  (case-lambda
   [() (buffer-mark current-buffer)]
   [(b) ((record-accessor buffer-rtd 4) b)]))

(define buffer-goal-column
  (case-lambda
   [() (buffer-goal-column current-buffer)]
   [(b) ((record-accessor buffer-rtd 5) b)]))

(define buffer-offset-line
  (case-lambda
   [() (buffer-offset-line current-buffer)]
   [(b) ((record-accessor buffer-rtd 6) b)]))

(define buffer-offset-column
  (case-lambda
   [() (buffer-offset-column current-buffer)]
   [(b) ((record-accessor buffer-rtd 7) b)]))

(define buffer-line
  (case-lambda
   [() (buffer-line current-buffer)]
   [(b) ((record-accessor buffer-rtd 8) b)]))

(define buffer-line-indices
  (case-lambda
   [() (buffer-line-indices current-buffer)]
   [(b) ((record-accessor buffer-rtd 9) b)]))

(define buffer-modified
  (case-lambda
   [() (buffer-modified current-buffer)]
   [(b) ((record-accessor buffer-rtd 10) b)]))

(define buffer-newline-char
  (case-lambda
   [() (buffer-newline-char current-buffer)]
   [(b) ((record-accessor buffer-rtd 11) b)]))

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
    (buffer-modified-set! b #t)
    (buffer-update-line-indices b)
    ;; Check point and mark are inside bounds.
    ;; Also calls buffer-update-line.
    (buffer-point-set! b (buffer-point b))
    (buffer-mark-set! b (buffer-mark b))]))

(define buffer-point-set!
  (case-lambda
   [(v) (buffer-point-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 3) b
           (min-max v 0 (buffer-length b)))
    (buffer-update-line b)]))

(define buffer-mark-set!
  (case-lambda
   [(v) (buffer-mark-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 4) b
           (min-max v 0 (buffer-length b)))]))

(define buffer-goal-column-set!
  (case-lambda
   [(v) (buffer-goal-column-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 5) b v)]))

(define buffer-offset-line-set!
  (case-lambda
   [(v) (buffer-offset-line-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 6) b
           (min-max v 0 (sub1 (vector-length (buffer-line-indices b)))))]))

(define buffer-offset-column-set!
  (case-lambda
   [(v) (buffer-offset-column-set! current-buffer v)]
   [(b v) (let* ([idx (buffer-line-index b (buffer-line b))]
                 [max (- (cdr idx) (car idx))])
            ((record-mutator buffer-rtd 7) b (min-max v 0 max)))]))

(define buffer-line-set!
  (case-lambda
   [(v) (buffer-line-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 8) b v)]))

(define buffer-line-indices-set!
  (case-lambda
   [(v) (buffer-line-indices-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 9) b v)]))

(define buffer-modified-set!
  (case-lambda
   [(v) (buffer-modified-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 10) b v)]))

(define buffer-newline-char-set!
  (case-lambda
   [(v) (buffer-newline-char-set! current-buffer v)]
   [(b v) ((record-mutator buffer-rtd 11) b v)]))

;; Helpers

(define buffer-append
  (case-lambda
   [(txt) (buffer-append current-buffer txt)]
   [(b txt) (buffer-content-set!
             b (string-append
                (buffer-content b) txt))]))

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

;; Names of temporary buffers start with * character.
(define buffer-temporary?
  (case-lambda
   [() (buffer-temporary? current-buffer)]
   [(b) (string-starts-with? (buffer-name b) "*")]))

(define buffer-valid-name?
  (lambda (name)
    ;; This needs to be improved, but for
    ;; now we just check it's not empty string.
    (> (string-length name) 0)))

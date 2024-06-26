;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; hacked - hacker's editor
;; Copyright (c) 2021 Pekka Laiho
;; License: GPLv3
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;; -------
;; Setters
;; -------

;; Other functions in this file use these functions
;; to set new location for point or new content
;; for the buffer.

(define set-point
  (lambda (pt)
    (if (or (< pt 0) (> pt (buffer-length))) #f
        (begin
          (buffer-point-set! pt)
          (reconcile-by-scrolling)
          #t))))

(define set-point-and-goal
  (lambda (pt)
    (let ([result (set-point pt)])
      (when result
        (buffer-goal-column-set! (buffer-column)))
      result)))

(define set-content
  (lambda (content)
    (buffer-content-set! content)
    (reconcile-by-scrolling)
    #t))

(define set-offset-line
  (lambda (n)
    (buffer-offset-line-set! n)
    (reconcile-by-moving-point)))

(define set-offset-column
  (lambda (n)
    (buffer-offset-column-set! n)
    (reconcile-by-moving-point)))

;; ---------
;; Reconcile
;; ---------

;; After moving the point or changing the
;; content of the buffer, it is possible
;; the point is no longer visible on the screen.
;;
;; We must reconcile point and scroll offset so
;; the point is visible again. We can reconcile
;; either by moving point or offset.

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

;; ----------
;; Boundaries
;; ----------

(define find-boundary-forward
  (lambda (boundary)
    (let ([i (string-find-char-sequence
              (buffer-content)
              boundary (buffer-point) #t)])
      (if i (add1 i) (buffer-length)))))

(define find-boundary-backward
  (lambda (boundary)
    (let ([i (string-find-char-sequence
              (buffer-content)
              boundary (sub1 (buffer-point)) #f)])
      (if i i 0))))

(define forward-to-boundary
  (lambda (boundary)
    (set-point-and-goal
     (find-boundary-forward boundary))))

(define backward-to-boundary
  (lambda (boundary)
    (set-point-and-goal
     (find-boundary-backward boundary))))

;; --------
;; Movement
;; --------

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
   [(n) (repeat-times
         (lambda () (forward-to-boundary word-boundary)) n)]))

;; Move point to beginning of previous word.
(define backward-word
  (case-lambda
   [() (backward-word 1)]
   [(n) (repeat-times
         (lambda () (backward-to-boundary word-boundary)) n)]))

;; Move point to end of sentence.
(define forward-sentence
  (case-lambda
   [() (forward-sentence 1)]
   [(n) (repeat-times
         (lambda () (forward-to-boundary sentence-boundary)) n)]))

;; Move point to beginning of sentence.
(define backward-sentence
  (case-lambda
   [() (backward-sentence 1)]
   [(n) (repeat-times
         (lambda () (backward-to-boundary (reverse sentence-boundary))) n)]))

;; Move point to next blank line.
(define forward-paragraph
  (case-lambda
   [() (forward-paragraph 1)]
   [(n) (repeat-times
         (lambda () (forward-to-boundary (buffer-paragraph-boundary))) n)]))

;; Move point to previous blank line.
(define backward-paragraph
  (case-lambda
   [() (backward-paragraph 1)]
   [(n) (repeat-times
         (lambda () (backward-to-boundary (buffer-paragraph-boundary))) n)]))

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
  (case-lambda
   [() (perform-query
        "Goto line: "
        ""
        (lambda (ls)
          (let ([l (string->number ls)])
            (if l (goto-line (sub1 l))
                (show-message "Invalid line number"))))
        #f)]
   [(l) (set-point
         (cond
          [(< l 0) 0]
          [(>= l (vector-length (buffer-line-indices))) (buffer-length)]
          [else
           (let ([idx (buffer-line-index l)])
             (min-max
              (+ (car idx) (buffer-goal-column))
              (car idx)
              (cdr idx)))]))]))

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

;; Move to first non-whitespace character of current line.
(define back-to-indentation
  (lambda ()
    (let* ([not-ws? (lambda (a) (not (or (char=? a #\space) (char=? a #\tab))))]
           [idx (buffer-line-index)]
           [result (string-find-char-forward-p (buffer-content) not-ws? (car idx))])
      (set-point-and-goal
       (if result (min result (cdr idx)) (cdr idx))))))

;; -------------------
;; Scrolling (offsets)
;; -------------------

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

(define delete-string
  (lambda (start end)
    (when (< start 0) (set! start 0))
    (when (> end (buffer-length)) (set! end (buffer-length)))
    (set-content
     (string-append
      (buffer-substring 0 start)
      (buffer-substring end (buffer-length))))))

;; Delete one character forward.
(define delete-character-forward
  (case-lambda
   [() (delete-character-forward 1)]
   [(n) (delete-string (buffer-point) (+ (buffer-point) n))]))

;; Delete one character backward.
(define delete-character-backward
  (case-lambda
   [() (delete-character-backward 1)]
   [(n) (let ([start (- (buffer-point) n)])
          (delete-string start (buffer-point))
          (set-point-and-goal start))]))

(define delete-word-forward
  (case-lambda
   [() (delete-word-forward 1)]
   [(n) (repeat-times
         (lambda () (delete-string
                     (buffer-point)
                     (find-boundary-forward word-boundary)))
         n)]))

(define delete-word-backward
  (case-lambda
   [() (delete-word-backward 1)]
   [(n) (repeat-times
         (lambda ()
           (let ([start (find-boundary-backward word-boundary)])
             (delete-string start (buffer-point))
             (set-point-and-goal start))) n)]))

(define delete-rest-of-line
  (lambda ()
    (let ([start (buffer-point)]
          [end (cdr (buffer-line-index))])
      ;; Add 1 when at the end of line to delete the linebreak.
      (when (and (= start end) (< end (buffer-length)))
        (set! end (add1 end)))
      (let ([content (buffer-substring start end)])
        (undo-push
         (lambda ()
           (insert-string content start)
           (set-point-and-goal start)))
        (delete-string start end)))))

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

;; Insert buffer-specific newline-character.
(define insert-newline
  (lambda ()
    (insert-character-forward (buffer-newline-char))))

;; Insert string.
(define insert-string
  (case-lambda
   [(txt) (insert-string txt (buffer-point))]
   [(txt idx)
    (set-content
     (string-append
      (buffer-substring 0 idx) txt
      (buffer-substring idx (buffer-length))))]))

;; -------
;; Buffers
;; -------

;; Add the given message to *messages* buffer
;; and optionally display it in minibuffer.
(define show-message
  (case-lambda
   [(message) (show-message message #t)]
   [(message on-minibuf)
    (when on-minibuf
      (show-on-minibuf message))
    (let ([buf (find-or-make-buffer "*messages*")])
      (buffer-append
       buf (string-append
            message
            (string (buffer-newline-char buf))))
      (buffer-point-set! buf (buffer-length buf))
      (when (eq? current-buffer buf)
        (reconcile-by-scrolling)))]))

;; Compare buffer names for sorting.
(define compare-buffer-names
  (lambda (a b)
    (string-ci<? a b)))

;; Completions for buffer name.
(define complete-buffer-name
  (lambda (start)
    (list-sort
     compare-buffer-names
     (let ([names (map
                   (lambda (a) (buffer-name a))
                   buffer-list)])
       (if (= (string-length start) 0) names
           (filter
            (lambda (a) (string-starts-with? a start))
            names))))))

;; Make a buffer the current buffer.
(define select-buffer
  (case-lambda
   [()
    (perform-query
     "Buffer: "
     ""
     (lambda (name) (if (buffer-valid-name? name)
                        (select-buffer (find-or-make-buffer name))
                        (show-message "Invalid buffer name")))
     complete-buffer-name)]
   [(b) (set! current-buffer b)
    (reconcile-by-scrolling)]))

(define select-previous-buffer
  (lambda ()
    (let ([b (previous-buffer)])
      (if b (select-buffer b) #f))))

(define select-next-buffer
  (lambda ()
    (let ([b (next-buffer)])
      (if b (select-buffer b) #f))))

;; Kill buffer and confirm from user if it is unsaved.
(define kill-buffer-confirm
  (case-lambda
   [() (kill-buffer-confirm current-buffer)]
   [(b) (if (and (buffer-modified b) (not (buffer-temporary? b)))
            (perform-confirm
             (format "Kill modified buffer ~a (y/n)? " (buffer-name b))
             (lambda () (kill-buffer b)) #f)
            (kill-buffer b))]))

;; Kill a buffer.
(define kill-buffer
  (lambda (b)
    (set! buffer-list (remq b buffer-list))
    (select-buffer
     (if (null? buffer-list)
         (make-buffer "*scratch*")
         (car buffer-list)))))

;; Re-read buffer from file.
(define revert-buffer
  (case-lambda
   [() (revert-buffer current-buffer)]
   [(b) (let ([filename (buffer-filename b)])
          (if filename
              (let ([content (read-file filename)])
                (if content
                    (begin
                      (buffer-content-set! b content)
                      (buffer-modified-set! b #f)
                      #t)
                    #f))
              #f))]))

;; ----------------------
;; Mark, Kill, Yank, Undo
;; ----------------------

(define kill-ring (list))

(define add-to-kill-ring
  (lambda (text)
    (set! kill-ring (cons text kill-ring))))

(define set-mark-at-point
  (lambda ()
    (let ([b current-buffer])
      (buffer-mark-set! b (buffer-point b))
      (show-message "Mark set"))))

(define exchange-point-and-mark
  (lambda ()
    (let* ([pt (buffer-point)])
      (set-point-and-goal (buffer-mark))
      (buffer-mark-set! pt))))

(define get-region
  (lambda ()
    (let* ([pt (buffer-point)]
           [mk (buffer-mark)]
           [start (if (< pt mk) pt mk)]
           [end (if (< pt mk) mk pt)])
      (cons start end))))

(define yank
  (lambda ()
    (if (null? kill-ring)
        (show-message "Kill ring is empty")
        (begin
          (let* ([content (car kill-ring)]
                 [len (string-length content)]
                 [pt (buffer-point)])
            (insert-string content pt)
            (set-point-and-goal (+ pt len))
            (undo-push
             (lambda ()
               (delete-string pt (+ pt len))
               (set-point-and-goal pt)))
            (show-message (format "Yanked ~d characters" len)))))))

(define copy-region
  (lambda ()
    (let* ([idx (get-region)]
           [content (buffer-substring (car idx) (cdr idx))])
      (add-to-kill-ring content)
      (show-message (format "Copied ~d characters"
                            (string-length content))))))

(define kill-region
  (lambda ()
    (let* ([idx (get-region)]
           [content (buffer-substring (car idx) (cdr idx))])
      (add-to-kill-ring content)
      (delete-string (car idx) (cdr idx))
      (set-point-and-goal (car idx))
      (undo-push
       (lambda ()
         (insert-string content (car idx))
         (set-point-and-goal (cdr idx))))
      (show-message (format "Killed ~d characters"
                            (string-length content))))))

(define undo-push
  (lambda (action)
    (buffer-undo-ring-set!
     (cons action (buffer-undo-ring)))))

(define undo-pop
  (lambda ()
    (if (null? (buffer-undo-ring))
        (show-message (format "No undo action"))
        (begin
          ((car (buffer-undo-ring)))
          (buffer-undo-ring-set!
           (cdr (buffer-undo-ring)))
          (show-message "Undo")))))

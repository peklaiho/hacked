;; Open file for debugging
(define debug-file
  (open-file-output-port
   "~/debug.txt"
   (file-options no-fail)
   (buffer-mode none)
   (make-transcoder (utf-8-codec))))

;; Define some utility functions
(define debug-log
  (lambda (obj)
    (write obj debug-file)
    (newline debug-file)
    (flush-output-port debug-file)))

(define read-file
  (lambda (filename)
    (let* ([f (open-file-input-port
               filename
               (file-options)
               (buffer-mode block)
               (make-transcoder (utf-8-codec)))]
           [content (get-string-all f)])
      (close-port f)
      content)))

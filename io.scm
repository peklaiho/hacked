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

(define home-directory
  (lambda ()
    (getenv "HOME")))

(define home-directory-char #\~)

(define add-trailing-directory-separator
  (lambda (dir)
    (string-append dir (string (directory-separator)))))

;; Replace home directory with ~
(define compact-directory
  (lambda (dir)
    (let ([home (home-directory)])
      (if (string-starts-with dir home)
          (string-append
           (string home-directory-char)
           (substring dir (string-length home) (string-length dir)))
          dir))))

(define expand-directory
  (lambda (dir)
    (let ([home (home-directory)])
      (if (string-starts-with dir (string home-directory-char))
          (string-append
           home
           (substring dir 1 (string-length dir)))
          dir))))

(define read-file
  (lambda (filename)
    (if (and (file-exists? filename) (file-regular? filename))
        (let* ([f (open-file-input-port
                   filename
                   (file-options)
                   (buffer-mode block)
                   (make-transcoder (utf-8-codec)))]
               [content (get-string-all f)])
          (close-port f)
          content) #f)))

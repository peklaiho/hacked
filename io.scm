;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; hacked - hacker's editor
;; Copyright (c) 2021 Pekka Laiho
;; License: GPLv3
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

;; Add directory separator (slash) at the
;; end of directory name if it doesn't exist.
(define add-trailing-directory-separator
  (lambda (dir)
    (let ([sep (string (directory-separator))])
    (if (string-ends-with? dir sep) dir
        (string-append dir sep)))))

;; Replace full path to home directory with ~
(define compact-directory
  (lambda (dir)
    (let ([home (home-directory)])
      (if (string-starts-with? dir home)
          (string-append
           (string home-directory-char)
           (substring dir (string-length home) (string-length dir)))
          dir))))

;; Replace ~ with full path to home directory
(define expand-directory
  (lambda (dir)
    (let ([home (home-directory)])
      (if (string-starts-with? dir (string home-directory-char))
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

(define combine-directories
  (lambda (start end)
    (string-append (add-trailing-directory-separator start) end)))

(define build-filename-completions
  (lambda (dir files)
    (map (lambda (a)
           (let ([name (combine-directories dir a)])
             (if (file-directory? name)
                 (add-trailing-directory-separator name)
                 name))) files)))

;; Completion functions take a string and return
;; a list of possible completions for that string.
(define complete-filename
  (lambda (dir)
    (if (string-ends-with? dir (string (directory-separator)))
        (if (not (file-directory? dir)) (list)
            (build-filename-completions dir (directory-list dir)))
        (let ([parent (path-parent dir)] [start (path-last dir)])
          (if (not (file-directory? parent)) (list)
              (build-filename-completions parent
                (filter (lambda (a) (string-starts-with? a start))
                        (directory-list parent))))))))

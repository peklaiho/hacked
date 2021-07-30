;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; hacked - hacker's editor
;; Copyright (c) 2021 Pekka Laiho
;; License: GPLv3
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

;; Read a file from disk.
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

;; Append two directories, adding directory separator if required.
(define combine-directories
  (lambda (start end)
    (string-append (add-trailing-directory-separator start) end)))

;; Add trailing directory separator to directories, but not files.
(define build-filename-completions
  (lambda (dir files)
    (map (lambda (a)
           (let ([name (combine-directories dir a)])
             (if (file-directory? name)
                 (add-trailing-directory-separator name)
                 name))) files)))

;; Compare filenames for sorting, sort directories first.
(define compare-filenames
  (lambda (a b)
    (cond
     [(and (file-directory? a) (not (file-directory? b))) #t]
     [(and (not (file-directory? a)) (file-directory? b)) #f]
     [else (string-ci<? a b)])))

;; Completion functions take a string and return
;; a list of possible completions for that string.
(define complete-filename
  (lambda (dir)
    (list-sort
     compare-filenames
     (if (string-ends-with? dir (string (directory-separator)))
         ;; Given string ends with directory separator:
         ;; Return all files inside the directory
         (if (not (file-directory? dir)) (list)
             (build-filename-completions dir (directory-list dir)))
         ;; Given string does NOT end with directory separator:
         ;; Return all files starting with the given filename
         (let ([parent (path-parent dir)] [start (path-last dir)])
           (if (not (file-directory? parent)) (list)
               (build-filename-completions parent
                 (filter (lambda (a) (string-starts-with? a start))
                         (directory-list parent)))))))))

;; Open a file and create new buffer for it.
(define open-file
  (case-lambda
   [()
    (perform-query
     "Open file: "
     (add-trailing-directory-separator
      (compact-directory (current-directory)))
     (lambda (n) (open-file n))
     complete-filename)]
   [(name)
    (let ([content (read-file name)])
      (if content
          (select-buffer (make-buffer (path-last name) content name))
          (show-on-minibuf "Unable to read file: ~a" name)))]))

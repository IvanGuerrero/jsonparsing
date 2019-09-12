;;;; 816335 Bryan Ivan Zhigui Guerrero

;;;; json-parse 

(defun json-parse (string)
  (if (stringp string)
      (json (make-string-input-stream string))  
    (if (streamp string )
        (json string)
      (error "error the param not is string or stream"))))

(defun json (stream)
  (let ((input-char (read-char (delete-space stream) t)))
    (cond
     ((char= input-char #\{)
      (json-obj stream))
     ((char= input-char #\[)
      (json-array stream)))))

;;;;json-obj

(defun json-obj (stream) 
  (let ((char-obj (read-char (delete-space stream) t)))
    (cond
     ((char= char-obj #\}) (list 'json-obj))
     ((char= char-obj #\") (progn (unread-char char-obj stream) (append '(json-obj) (json-members stream))))
     (t 
      (error "error json-obj")))))

(defun json-members (stream)
  (let ((pair (read-char (delete-space stream) t)))     
    (if (char= pair #\") 
        (cons (json-pair stream)
              (let ((char-virg (read-char (delete-space stream) t)))
                (cond
                 ((char= char-virg #\,) (json-members (delete-space stream)))
                 ((char= char-virg #\}) nil)
                 (t (error "error json-members-create-list")))))
      (error "error json-members"))))

(defun json-pair (stream)
  (let ((key (json-string stream)))
    (let ((char-double (read-char (delete-space stream) t)))
      (if (char= char-double #\:)
          (let ((value (json-value (delete-space stream))))
            (list key value ))
          (error "error make pair")))))
    
;;;; json_array
(defun json-array (stream)
  (let ((char-array (read-char (delete-space stream) t)))
    (if (char= char-array #\])
        (list 'json-array)
      (progn (unread-char char-array stream)
        (append '(json-array) (json-elements stream))))))

(defun json-elements (stream)
  (cons (json-value stream)
        (let ((char-virg (read-char (delete-space stream) t)))
          (cond
           ((char= char-virg #\,) (json-elements (delete-space stream)))
           ((char= char-virg #\]) nil)
           (t (error "error json-elements-create-list"))))))

;;;;make-value
(defun json-value (stream)
  (let ((char-value (read-char stream t)))
    (cond
     ((char= char-value #\") (json-string stream))
     ((controll-number-val char-value) (progn (unread-char char-value stream)
                                           (json-number stream)))
     ((or
      (char= char-value #\{)
      (char= char-value #\[)) (progn (unread-char char-value stream)
                                (json stream)))
     (t 
      (error "error to convert value")))))    

(defun json-string (stream)
  (let ((string (coerce (json-string-aux stream) 'string)))
    (if (stringp string)
        string      
      (error "error to convert json-string"))))

(defun json-string-aux (stream)
  (let ((char-controll (read-char  stream t)))
    (if (char= char-controll #\")
        nil
      (cons char-controll
            (json-string-aux stream)))))

(defun json-number (stream)
  (let ((list-digit (json-digit stream)))
    (if (null (control-float list-digit))
        (first (list (parse-integer (coerce list-digit 'string))))
      (parse-float (coerce list-digit 'string)))))

(defun json-digit (stream)
  (let ((char-digit (read-char stream t)))
    (if (or
         (char= char-digit #\})
         (char= char-digit #\])
         (char= char-digit #\,)
         (char= char-digit #\Space))
        (progn (unread-char char-digit stream)
          nil)
      (cons char-digit
            (json-digit stream)))))

(defun control-float (list-char)
  (let ((is-punct (first list-char)))
    (if (null list-char)
         nil
      (if (char= is-punct #\.)
          t
        (control-float (rest list-char))))))

(defun controll-number-val (char)
  (if (or
       (char= char #\-)
	   (char= char #\+)
       (and (char>= char #\0) (char<= char #\9)))
      T))
   
(defun delete-space (stream)
  (let ((char (read-char stream t)))
    (if (or
         (char= char #\Space)
         (char= char #\Tab)
         (char= char #\Newline)
         (char= char #\Return)
         (char= char #\Linefeed))
        (delete-space stream)
        (progn (unread-char char stream)
              stream))))

;;;; json-get

(defun json-get (list-o-a &rest field)
  (if (and (listp list-o-a) (>= (list-length field) 1))  ;; caso paso nella quale field è una lista
    (json-get-json list-o-a field)

    (t (error "error"))))

;;;;json-get-json

(defun json-get-json (list fields)
  (cond
   ((and (= (list-length fields) 1) (numberp (first fields)) (is-json-array list))
      (json-get-array (rest list) (first fields)))

   ((and (= (list-length fields) 1) (stringp (first fields)) (is-json-obj list))
      (json-get-obj (rest list) (first fields)))

   ((and (> (list-length fields) 1) (numberp (first fields)) (is-json-array list))
      (json-get-json (json-get-array (rest list) (first fields)) (rest fields)))

   ((and (> (list-length fields) 1) (stringp (first fields)) (is-json-obj list))
      (json-get-json (json-get-obj (rest list) (first fields)) (rest fields)))))

;;;; json-get-obj search the key and return the val 

(defun json-get-obj (table key)
  (cond
   ((null table) (error "error found key, not exist"))
   ((equal (first (first table)) key) (second (first table)))
   (t (json-get-obj (rest table) key))))

;;;; json-get-array 

(defun json-get-array (list pos)
  (if (and (>= pos 0) (< pos (list-length list)))
      (nth pos list)
    
    (error "error not of bound index")))

(defun is-json-array (list)
  (if (listp list)
      (equal (first list) 'json-array)
    
    (t (error "error not list to array"))))

(defun is-json-obj (list)
  (if (listp list)
      (equal (first list) 'json-obj)
    
    (t (error "error not list to obj"))))

(defun is-json (list)
  (or (is-json-array list)
      (is-json-obj list)))

;;;; json-write

(defun json-write (json filename)
      (with-open-file (out filename 
                       :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)
    (json-v-write json out) filename))

;;;; json-val-write incomincia a costruire ricorsivamente 

(defun json-v-write (json stream) 
 (cond
  ((is-json-array json) (json-array-write (rest json) stream))
  ((is-json-obj json) (json-obj-write (rest json) stream))
  (t (error "error json-write"))))

(defun json-array-write (json stream)
  (format stream "[~{~A~^, ~}]" (json-elements-write json) ))

(defun json-elements-write (json) 
  (mapcar (lambda (e) (json-value-write e nil)) json))

(defun json-obj-write (json stream)
  (format stream "{~{~A~^, ~}}" (json-members-write json)))

(defun json-members-write (members)
  (mapcar 'json-pair-write members))

(defun json-pair-write (pair)
  (format nil "~S : ~A" (first pair) (json-value-write (second pair) nil)))


(defun json-value-write (json out)
  (cond
   ((numberp json) (json-number-write json out))
   ((stringp json) (format out "~S" json))
   ((is-json json) (json-v-write json out))))


(defun json-number-write (json stream)
  (cond 
   ((integerp json) (format stream "~D" json))
   ((floatp json) (format stream "~F" json))
   (t (error "error write number to file"))))

(defun json-load (filename)
  (with-open-file (stream filename
                          :direction :input
                          :if-does-not-exist :error)
    (json-parse stream)))

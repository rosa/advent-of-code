; --- Day 4: Secure Container ---

(defun number-to-digits (number)
  (map 'list #'digit-char-p (princ-to-string number)))

; Your puzzle input is 158126-624574.
(defparameter *range*
  (list (number-to-digits 158126) (number-to-digits 624574)))

; Two adjacent digits are the same (like 22 in 122345).
; Going from left to right, the digits never decrease,
; they only ever increase or stay the same (like 111123 or 135679).
(defun has-two-adjacent-same-digits (password)
  (if (< (length password) 2) nil
    (or (= (first password) (second password))
      (has-two-adjacent-same-digits (cdr password)))))

(defun digits-never-decrease (password)
  (if (< (length password) 2) T
    (and (<= (first password) (second password))
      (digits-never-decrease (cdr password)))))

(defun password-candidates (start end)
  (loop for i from start below end collect i))

(defun valid-password (number criteria)
  (let ((password (number-to-digits number)))
    (and (funcall criteria password)
      (digits-never-decrease password))))

(defun count-passwords (start end criteria)
  (count-if (lambda(x) (valid-password x criteria)) (password-candidates start end)))

; > (count-passwords 158126 624574 #'has-two-adjacent-same-digits)
; 1665

; --- Part Two ---

; The two adjacent matching digits are not part of a larger group of matching digits.
(defun has-two-adjacent-same-digits-not-in-group (password &optional prev current_count)
  (cond ((null current_count) (has-two-adjacent-same-digits-not-in-group (cdr password) (car password) 1))
    ((and (not (null password)) (= prev (car password))) (has-two-adjacent-same-digits-not-in-group (cdr password) prev (+ current_count 1)))
    ((= current_count 2) T)
    ((null password) nil)
    (T (has-two-adjacent-same-digits-not-in-group (cdr password) (car password) 1))))

; > (count-passwords 158126 624574 #'has-two-adjacent-same-digits-not-in-group)
; 1131

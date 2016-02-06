(defvar qrencode-border 4)
(defvar qrencode-hzoom  2)
(defvar qrencode-vzoom  1)
(defvar qrencode-buffer-name "*qrcode*")

(defvar qrencode-use-faces t)

(defvar qrencode-checker-char-black "#")
(defvar qrencode-checker-char-white " " )

(defface qrencode-checker-black
  '((t (:background "black")))
  "qrencode: black checker face"
  :group 'qrencode)

(defface qrencode-checker-white
  '((t (:background "white")))
  "qrencode: white checker face"
  :group 'qrencode)

(defun qrencode-swap-black-white ()
  (interactive)
  (psetf
   qrencode-checker-char-white qrencode-checker-char-black
   qrencode-checker-char-black qrencode-checker-char-white)
  (message "Now black is char \"%s\", white is char \"%s\""
           qrencode-checker-char-black
           qrencode-checker-char-white))

(defun qrencode--insert-checker-at-point (blackp)
  (if qrencode-use-faces
      (progn        
        (insert " ")
        (add-text-properties
         (1- (point)) (point)
         (list
          'face
          (if blackp 'qrencode-checker-black 'qrencode-checker-white))))
    (insert
     (if blackp
         qrencode-checker-char-black
       qrencode-checker-char-white))))

(defun qrencode--insert-checker (mtx i0 j0)
  (qrencode--insert-checker-at-point
   (if (and (>= i 0) (< i (length mtx)) (>= j 0) (< j (length (aref mtx i))))
       (memq (aref (aref mtx j) i) '(:dark :fdark))
     nil)))

;;;###autoload
(defun qrencode-string (msg)
  "insert an ASCII QR in the current buffer"
  (interactive "sMessage to encode:")
  (let ((q (matrix
            (encode-symbol
             (with-temp-buffer
               (insert msg)
               (toggle-enable-multibyte-characters -1)
               (buffer-substring-no-properties (point-min) (point-max)))
             nil nil nil))))
    (save-window-excursion
      (set-buffer (get-buffer-create qrencode-buffer-name))
      (delete-region (point-min) (point-max))
      (goto-char (point-min))
      (loop for i from (- qrencode-border) to (+ qrencode-border (1- (length q))) do
            (dotimes (ivzoom qrencode-vzoom)
              (progn
                (loop for j from (- qrencode-border) to (+ qrencode-border (1- (length q))) do
                      (dotimes
                          (ihzoom qrencode-hzoom)
                        (qrencode--insert-checker q i j)))
                (insert "\n"))))
      (goto-char (point-min)))))

;;;###autoload
(defun qrencode-region (from to)
  (interactive "r")
  (when (region-active-p)
    (qrencode-string
     (buffer-substring-no-properties from to))))

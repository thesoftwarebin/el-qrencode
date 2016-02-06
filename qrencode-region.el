(defvar qrencode-border 4)
(defvar qrencode-hzoom  2)
(defvar qrencode-vzoom  1)

(defun qrencode-insert-qr-ascii-string (msg)
  "insert an ASCII QR in the current buffer"
  (interactive "sMessage to encode:")
  (let ((q (matrix (encode-symbol msg nil nil nil)))
        (fn (lambda (q i0 j0)
              (if (and (>= i 0) (< i (length q)) (>= j 0) (< j (length (aref q i))))
                  (if (memq (aref (aref q j) i) '(:dark :fdark)) " " #x2588)
                #x2588))))
    (save-window-excursion
      (set-buffer "*QR code*")
      (delete-region (point-min) (point-max))
      (goto-char (point-min))
      (loop for i from (- qrencode-border) to (+ qrencode-border (1- (length q))) do
            (dotimes (ivzoom qrencode-vzoom)
              (progn
                (loop for j from (- qrencode-border) to (+ qrencode-border (1- (length q))) do
                      (dotimes (ihzoom qrencode-hzoom) (insert (funcall fn q i j))))
                (insert "\n"))))
      (goto-char (point-min)))))


(defun qrencode-insert-qr-ascii-region (from to)
  (interactive "r")
  (qrencode-insert-qr-ascii-string
   (buffer-substring-no-properties from to)))

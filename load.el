;; a dummy debug/trace function
(if (not (fboundp 'dbg))
    (defun dbg (&rest args)))

(load-file "rs-ecc/bch-ecc.el")
(load-file "rs-ecc/galois.el")
(load-file "rs-ecc/rs-ecc.el")

(load-file "qrencode/bstream.el")
(load-file "qrencode/codeword.el")
(load-file "qrencode/encode.el")
(load-file "qrencode/input.el")
(load-file "qrencode/mask.el")
(load-file "qrencode/matrix.el")
(load-file "qrencode/modes.el")
(load-file "qrencode/qrspec.el")

(encode-symbol "ciao" nil nil nil)

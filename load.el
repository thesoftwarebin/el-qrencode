;; -*- lexical-binding: t -*-

;; a dummy debug/trace function
(if (not (fboundp 'dbg))
    (defun dbg (&rest args)))

(load-file "rs-ecc/bch-ecc.el")
(load-file "rs-ecc/galois.el")
(load-file "rs-ecc/rs-ecc.el")

(load-file "qrencode/qrspec.el")
(load-file "qrencode/bstream.el")
(load-file "qrencode/codeword.el")
(load-file "qrencode/encode.el")
(load-file "qrencode/input.el")
(load-file "qrencode/mask.el")
(load-file "qrencode/matrix.el")
(load-file "qrencode/modes.el")

(load-file "emacs-commands.el")

;; raise memory limits, else Emacs will complain
(setf max-specpdl-size 12000)
(setf max-lisp-eval-depth 12000)

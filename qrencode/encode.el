;; -*- lexical-binding: t -*-

;;;; Copyright (c) 2011-2014 jnjcc, Yste.org. All rights reserved.
;;;;
;;;; final QR code symbol

;; (in-package #:cl-qrencode)

(require 'cl)
(require 'eieio)

(defclass qr-symbol ()
  ((matrix :initform nil :initarg :matrix :reader matrix
           :documentation "qr code symbol as matrix")
   (modules :initform nil :initarg :modules :reader modules
            :documentation "qr code symbol modules")))

;; (defmethod print-object ((symbol qr-symbol) stream)
;;   (fresh-line stream)
;;   (with-slots (matrix modules) symbol
;;     (format stream "qr symbol ~A x ~A:~%" modules modules)
;;     (dotimes (i modules)
;;       (dotimes (j modules)
;;         (if (dark-module-p matrix i j)
;;             (format stream "1 ")
;;             (format stream "0 ")))
;;       (format stream "~%"))))

;;; FIXME: other encodings???
(defun ascii->bytes (text)
  (map 'list #'identity text))

(defun bytes->input (bytes version level mode)
  (setf version (min (max version 1) 40))
  (let ((input (make-instance 'qr-input :bytes bytes :qrversion version
                              :ec-level level :mode mode)))
    (data-encoding input)
    (ec-coding input)
    (structure-message input)
    (module-placement input)
    input))

(defun input->symbol (input)
  "encode qr symbol from a qr-input"
  (multiple-value-bind (matrix mask-ref)
      (data-masking input)
    (declare (ignore mask-ref))
    (let ((modules (matrix-modules (qrversion input))))
      (make-instance 'qr-symbol :matrix matrix :modules modules))))

(defun encode-symbol-bytes (bytes version level mode)
  "encode final qr symbol from BYTES list"
  (when (null version) (setf version 1))
  (when (null level) (setf level :level-m))
  (let ((input (bytes->input bytes version level mode)))
    (dbg :dbg-input "version: ~A; segments: ~A~%" (qrversion input)
         (segments input))
    (input->symbol input)))

;;;-----------------------------------------------------------------------------
;;; One Ring to Rule Them All, One Ring to Find Them,
;;; One Ring to Bring Them All and In the Darkness Blind Them:
;;;   This function wraps all we need.
;;;-----------------------------------------------------------------------------
;; (sdebug :dbg-input)
(defun encode-symbol (text version level mode)
  "encode final qr symbol, unless you know what you are doing, leave MODE NIL"
  (when (null version) (setf version 1))
  (when (null level) (setf level :level-m))
  (let ((bytes (ascii->bytes text)))
    (encode-symbol-bytes bytes version level mode)))

;; -*- lexical-binding: t -*-

;;;; Copyright (c) 2011-2014 jnjcc, Yste.org. All rights reserved.
;;;;

;; (in-package #:cl-qrencode)
(require 'cl)
(require 'eieio)

(defclass qr-input ()
  ((bytes
    :initform nil :initarg :bytes :reader bytes ;; :type list
    :documentation "list of bytes to be encoded")
   (qrversion
    :initform 1 :initarg :qrversion :reader qrversion
    :documentation "version of qr symbol, adapted according to BYTES")
   (ec-level ; cannot be NIL
    :initform :level-m :initarg :ec-level :reader level)
   (mode
    :initform nil :initarg :mode :reader mode ;; :type (or nil qr-mode)
    :documentation "if supplied, we force all BYTES to be under MODE,
therefore, unless you know exactly what you are doing, leave this NIL")
   (cur-byte
    :initform 0 :accessor cur-byte
    :documentation "index of BYTES during data analysis")
   (segments
    :initform nil :accessor segments ;; :type list
    :documentation
    "list of list, of the form ((:mode1 byte ...) (:mode2 byte ...) ...)")
   (bstream
    :initform nil :reader bstream ;; :type list
    :documentation "list of 0-1 values after encoding SEGMENTS")
   (blocks
    :initform nil :reader blocks ;; :type list
    :documentation "list of list, of the form ((codeword ...) (codeword ...) ...)
after converting BSTREAM to codewords")
   (ecc-blocks ; error correction blocks
    :initform nil :reader ecc-blocks ;; :type list
    :documentation "list of list, ec codewords corresponding to BLOCKS")
   (msg-codewords
    :initform nil :reader qrmessage ;; :type list
    :documentation "list of codewords from BLOCKS & ECC-BLOCKS,
interleaving if neccessary")
   (matrix
    :initform nil :accessor matrix
    :documentation "raw QR code symbol (without masking) as matrix")))

(defmethod initialize-instance :after ((input qr-input) &rest args)
  (declare (ignore args))
  (validate-and-analysis input))

;;; 0) Data analysis
(defgeneric validate-and-analysis (input)
  "adapt VERSION according to BYTES, and fill SEGMENTS slot")
;;; 1) Data encoding
(defgeneric data-encoding (input)
  "encode SEGMENTS into BSTREAM slot")
;;; 2) Error correction coding
(defgeneric ec-coding (input)
  "split BSTREAM into BLOCKS, do rs-ecc, and fill ECC-BLOCKS")
;;; 3) Structure final message
(defgeneric structure-message (input)
  "interleaving BLOCKS and ECC-BLOCKS into MSG-CODEWORDS")
;;; 4) Codeword placement in matrix, a.k.a, raw QR code symbol
(defgeneric module-placement (input)
  "write MSG-CODEWORDS into the raw (without masking) MATRIX")
;;; 5) Data masking & Format information
(defgeneric data-masking (input)
  "mask MATRIX with best pattern, generate the final symbol")

(defgeneric data-analysis (input)
  "BYTES -> SEGMETS, switch bewteen modes as necessary to
achieve the most efficient conversion of data")
(defgeneric redo-data-analysis (input)
  "VERSION changed, reset CUR-BYTE and redo data analysis")
(defgeneric analyse-byte-mode (input &optional seg))
(defgeneric analyse-alnum-mode (input &optional seg))
(defgeneric analyse-numeric-mode (input &optional seg))
(defgeneric analyse-kanji-mode (input &optional seg))
(defgeneric append-cur-byte (input &optional seg)
  "append CUR-BYTE of BYTES into SEGMENTS")
(defun mode-analyse-func (mode)
  "put CUR-BYTE into MODE, and then look at following BYTES for new segment"
  (case mode
    (:byte #'analyse-byte-mode)
    (:alnum #'analyse-alnum-mode)
    (:numeric #'analyse-numeric-mode)
    (:kanji #'analyse-kanji-mode)))

(defmethod data-analysis ((input qr-input))
  (block data-analysis-block
    (with-slots (mode cur-byte segments) input
      (when mode ; MODE supplied
        (let ((seg (append (list mode) (bytes input))))
          (setf cur-byte (length (bytes input)))
          (setf segments (append segments (list seg))))
        (return-from data-analysis-block)))
    (with-slots (bytes qrversion segments) input
      (let ((init-mode (select-init-mode bytes qrversion)))
        (funcall (mode-analyse-func init-mode) input)))))

(defmethod redo-data-analysis ((input qr-input))
  (with-slots (cur-byte segments) input
    (setf cur-byte 0)
    (setf segments nil)
    (data-analysis input)))

(defun select-init-mode (bytes version)
  "optimization of bitstream length: select initial mode"
  ;;(declare (type list bytes))
  (let ((init-xor (xor-subset-of bytes)))
    (case init-xor
      (:byte :byte)
      (:kanji
       (case (xor-subset-of (nthcdr 2 bytes))
         ((:numeric :alnum) :kanji)
         (:byte
          (let ((nunits (ecase (version-range version)
                          ((0 1) 5)
                          (2 6))))
            (if (every-unit-matches (nthcdr 3 bytes) 2 nunits :kanji)
                :byte
                :kanji)))
         (otherwise :kanji)))
      (:alnum
       (let ((nunits (ecase (version-range version)
                       (0 6) (1 7) (2 8))))
         ;; number of units (characters) match :alnum, followed by a :byte unit
         (multiple-value-bind (n last-mode) (nunits-matches (cdr bytes) :alnum)
           (if (and (< n nunits) (eq last-mode :byte))
               :byte
               :alnum))))
      (:numeric
       (let ((nbunits (ecase (version-range version)
                        ((0 1) 4) (2 5)))
             (naunits (ecase (version-range version)
                        (0 7) (1 8) (2 9))))
         (multiple-value-bind (n last-mode) (nunits-matches (cdr bytes) :numeric)
           (if (and (< n nbunits) (eq last-mode :byte))
               :byte
               (if (and (< n naunits) (eq last-mode :alnum))
                   :alnum
                   :numeric))))))))

;;; UNIT: character under a certain mode,
;;;   a byte under :numeric :alnum & :byte, or a byte-pair under :kanji
(defun every-unit-matches (bytes usize nunits mode)
  "if every unit of USZIE bytes (at most NUNITS unit) within BYTES matches MODE"
  ;; (declare (type list bytes) (type qr-mode mode))
  (block every-unit-matches-block
    (when (>= (length bytes) (* usize nunits))
      (dotimes (i nunits)
        (let ((b (nthcdr (* usize i) bytes)))
          (unless (eq (xor-subset-of b) mode)
            (return-from every-unit-matches-block nil))))
      (return-from every-unit-matches-block t))))

(defun nunits-matches (bytes mode)
  "(number of units that matches MODE, and mode for the first unmatched unit)"
  ;; (declare (type list bytes) (type qr-mode mode))
  (let ((usize (ecase mode
                 ((:byte :alnum :numeric) 1)
                 ;; as for :kanji, 2 bytes forms a single unit
                 (:kanji 2)))
        (nunits 0))
    (do ((b bytes (nthcdr usize b)))
        ((or (null b)
             (not (eq (xor-subset-of b) mode)))
         (values nunits (xor-subset-of b)))
      (incf nunits))))

(defmethod analyse-byte-mode ((input qr-input) &optional seg)
  ;; (declare (type list seg))
  (block analyse-byte-mode-block
    (when (null seg)
      (setf seg '(:byte)))
    (setf seg (append-cur-byte input seg))
    (unless seg
      (return-from analyse-byte-mode-block))
    (with-slots (bytes cur-byte qrversion segments) input
      (let* ((range (version-range qrversion))
             (nkunits (ecase range ; number of :kanji units before more :byte
                        (0 9) (1 12) (2 13)))
             (nanuits (ecase range ; number of :alnum units before more :byte
                        (0 11) (1 15) (2 16)))
             (nmunits1 (ecase range ; number of :numeric units before more :byte
                         (0 6) (1 8) (2 9)))
             (nmunits2 (ecase range ; number of :numeric units before more :alnum
                         (0 6) (1 7) (2 8)))
             (switch-mode nil))
        (multiple-value-bind (nmatches last-mode)
            (nunits-matches (nthcdr cur-byte bytes) :kanji)
          (and (>= nmatches nkunits) (eq last-mode :byte)
               (setf switch-mode :kanji)))
        (unless switch-mode
          (multiple-value-bind (nmatches last-mode)
              (nunits-matches (nthcdr cur-byte bytes) :alnum)
            (and (>= nmatches nanuits) (eq last-mode :byte)
                 (setf switch-mode :alnum))))
        (unless switch-mode
          (multiple-value-bind (nmatches last-mode)
              (nunits-matches (nthcdr cur-byte bytes) :numeric)
            (case last-mode
              (:byte (and (>= nmatches nmunits1)
                          (setf switch-mode :numeric)))
              (:alnum (and (>= nmatches nmunits2)
                           (setf switch-mode :numeric))))))
        (if switch-mode
            (progn
              ;; current segment finished, add a new SWITCH-MODE segment
              (setf segments (append segments (list seg)))
              (setf seg (list switch-mode)))
          (setf switch-mode :byte))
        (funcall (mode-analyse-func switch-mode) input seg)))))

(defmethod analyse-alnum-mode (input &optional seg)  
  (block analyse-alnum-mode-block
    (when (null seg)
      (setf seg '(:alnum)))
    (setf seg (append-cur-byte input seg))
    (unless seg
      (return-from analyse-alnum-mode-block))
    (with-slots (bytes cur-byte qrversion segments) input
      (let ((nmunits (ecase (version-range qrversion)
                       (0 13) (1 15) (2 17)))
            (switch-mode nil))
        (when (>= (car (nunits-matches (nthcdr cur-byte bytes) :kanji)) 1)
          (setf switch-mode :kanji))
        (unless switch-mode
          (when (>= (car (nunits-matches (nthcdr cur-byte bytes) :byte)) 1)
            (setf switch-mode :byte)))
        (unless switch-mode
          (multiple-value-bind (nmatches last-mode)
              (nunits-matches (nthcdr cur-byte bytes) :numeric)
            (and (>= nmatches nmunits) (eq last-mode :alnum)
                 (setf switch-mode :numeric))))
        (if switch-mode
            (progn
              (setf segments (append segments (list seg)))
              (setf seg (list switch-mode)))
          (setf switch-mode :alnum))
        (funcall (mode-analyse-func switch-mode) input seg)))))

(defmethod analyse-numeric-mode (input &optional seg)
  ;; (declare (type list seg))
  (block analyse-numeric-mode-block
    (when (null seg)
      (setf seg '(:numeric)))
    (setf seg (append-cur-byte input seg))
    (unless seg
      (return-from analyse-numeric-mode-block))
    (with-slots (bytes cur-byte qrversion segments) input
      (let ((switch-mode nil))
        (when (>= (car (nunits-matches (nthcdr cur-byte bytes) :kanji)) 1)
          (setf switch-mode :kanji))
        (unless switch-mode
          (when (>= (car (nunits-matches (nthcdr cur-byte bytes) :byte)) 1)
            (setf switch-mode :byte)))
        (unless switch-mode
          (when (>= (car (nunits-matches (nthcdr cur-byte bytes) :alnum)) 1)
            (setf switch-mode :alnum)))
        (if switch-mode
            (progn
              (setf segments (append segments (list seg)))
              (setf seg (list switch-mode)))
          (setf switch-mode :numeric))
        (funcall (mode-analyse-func switch-mode) input seg)))))

(defmethod append-cur-byte ((input qr-input) &optional seg)
  "if CUR-BYTE is the last byte, return nil"
  ;;(declare (type list seg))
  (block append-cur-byte-block
    (with-slots (bytes cur-byte segments) input
      (setf seg (append seg (list (nth cur-byte bytes))))
      (incf cur-byte)
      (when (>= cur-byte (length bytes))
        (setf segments (append segments (list seg)))
        (setf seg nil))
      (return-from append-cur-byte-block seg))))

(defmethod analyse-kanji-mode (input &optional seg)
  (when (null seg)
    (setf seg '(:byte)))
  (with-slots (bytes cur-byte segments) input
    (setf seg (append seg (nthcdr cur-byte bytes)))
    (setf cur-byte (length bytes))
    (setf segments (append segments (list seg)))))

(defmethod validate-and-analysis ((input qr-input))
  (with-slots ((level ec-level) segments) input
    (unless (<= 1 (qrversion input) 40)
      (error "version %s out of bounds" (qrversion input)))
    (do ((prev -1))
        ((<= (qrversion input) prev))
      (setf prev (qrversion input))
      (redo-data-analysis input)
      (cl-labels ((seg-bstream-len (seg)
                 (segment-bstream-length seg (qrversion input))))
        (let* ((blen (reduce #'+ (mapcar #'seg-bstream-len segments)
                             :initial-value 0))
               (min-v (minimum-version prev (ceiling blen 8) level)))
          (if min-v
              (setf (slot-value input 'qrversion) min-v)
              (error "no version to hold %s bytes" (ceiling blen 8))))))))

(defmethod data-encoding ((input qr-input))
  (with-slots (qrversion (level ec-level) segments) input
    (cl-labels ((seg->bstream (seg)
               (segment->bstream seg qrversion)))
      (let* ((bs (reduce #'append (mapcar #'seg->bstream segments)
                         :initial-value nil))
             (tt (terminator bs qrversion level))
             ;; connect bit streams in all segment, with terminator appended
             (bstream (append bs tt)))
        ;; add padding bits
        (setf bstream (append bstream (padding-bits bstream)))
        ;; add pad codewords, finishes data encoding
        (setf (slot-value input 'bstream)
              (append bstream
                      (pad-codewords bstream qrversion level)))))))

(defmethod ec-coding ((input qr-input))
  (with-slots (qrversion (level ec-level) bstream) input
    (let ((codewords (bstream->codewords bstream))
          (blocks nil)
          (ecc-blocks nil)
          ;; RS error correction obj for blk1 & blk2
          (rs1 nil)
          (rs2 nil))
      (multiple-value-bind (ecc-num blk1 data1 blk2 data2)
          (ecc-block-nums qrversion level)
        (when (> blk1 0)
          (setf rs1 (make-instance 'rs-ecc :k data1 :ec ecc-num)))
        (when (> blk2 0)
          (setf rs2 (make-instance 'rs-ecc :k data2 :ec ecc-num)))
        (dotimes (i blk1)
          (setf blocks
                (append blocks (list (subseq codewords 0 data1))))
          (setf codewords (nthcdr data1 codewords)))
        (dotimes (i blk2)
          (setf blocks
                (append blocks (list (subseq codewords 0 data2))))
          (setf codewords (nthcdr data2 codewords)))
        (dotimes (i blk1)
          (setf ecc-blocks
                (append ecc-blocks (list (ecc-poly rs1 (nth i blocks))))))
        (dotimes (i blk2)
          (setf ecc-blocks
                (append ecc-blocks (list (ecc-poly rs2 (nth (+ i blk1) blocks))))))
        (setf (slot-value input 'blocks) blocks)
        (setf (slot-value input 'ecc-blocks) ecc-blocks)))))

(defmethod structure-message ((input qr-input))
  (with-slots (qrversion (level ec-level) blocks ecc-blocks) input
    (let ((final nil))
      (multiple-value-bind (ecc-num blk1 data1 blk2 data2)
          (ecc-block-nums qrversion level)
        (declare (ignore ecc-num))
        (setf (slot-value input 'msg-codewords)
              (append final
                      ;; interleave data blocks, data blocks may differ in length
                      (take-data-in-turn blocks blk1 data1 blk2 data2)
                      ;; we know error correction blocks are of the same length
                      (take-in-turn ecc-blocks)))))))

(defmethod module-placement ((input qr-input))
  (setf (matrix input) (make-matrix (qrversion input) nil))
  (with-slots (qrversion msg-codewords matrix) input
    ;; Function pattern placement
    (function-patterns matrix qrversion)
    ;; Symbol character placement
    (let ((rbits (remainder-bits qrversion))
          (bstream nil))
      (cl-labels ((dec->byte (codeword)
                 (decimal->bstream codeword 8)))
        (setf bstream (append (reduce #'append (mapcar #'dec->byte msg-codewords))
                              ;; data capacity of _symbol_ does not divide by 8
                              (make-list rbits 0))))
      (symbol-character bstream matrix qrversion))))

(defmethod data-masking ((input qr-input))
  "(masked matrix, mask pattern reference)"
  (with-slots (qrversion (level ec-level) matrix) input
    (let ((modules (matrix-modules qrversion)))
      (multiple-value-bind (masked indicator)
          (choose-masking matrix modules level)
        (values masked (mask-pattern-ref indicator))))))

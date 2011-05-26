
(in-package :scenic)

;;; CONTAINER class.

(defclass container (widget)
  ((children :accessor children :initarg :children :initform nil)))

(declaim (optimize (debug 3)))

(defmethod initialize-instance :after ((instance container) &rest initargs)
  (declare (ignore initargs))
  (mapc (lambda (widget)
          (setf (parent widget) instance))
        (children instance)))

(defmethod paint-order-walk ((object container) callback)
  (when (funcall callback object)
    (mapc (lambda (child) (paint-order-walk child callback))
          (children object))))

(defmethod (setf children) :after (value (instance container))
  (mapc (lambda (child) (setf (parent child) instance))
        (children instance)))

;;; BOX class.

;; The BOX will arrange its contents horizontally or vertically,
;; according to a 'layout spec' and the sizing preferences for each
;; child.
;;
;; For horizontal boxes, all children have the same height (the
;; minimum between maximum height of the children and the maximum size
;; specified for the box) and the term 'size/space' below refers to width.
;;
;; Vertical boxes will behave similarly for width, with 'size/space'
;; meaning height.
;;
;; The 'layout spec' is a list of layout options, one layout option
;; specified for each child.
;;
;; The layout option for a child can be:
;;
;; * :auto - the child will take as much space as it requires;
;; * '(n :px) - n is the size in pixels for the child;
;; * '(n :ext) - the child fill fill the space proportionally;
;;
;; If the option is '(n ext), n is used to determine the child's share
;; in the remaining space (if all exts have n 1, they will receive an
;; equal share of the remaining space in the widget; if there is an
;; ext with n 2 and the others have n 1, the one with n 2 will receive
;; a double allowance of space).
;;
;; The algorithm for calculating the sizes is as follows:
;;
;; 1. All '(n px) layout options are summed and their sum is
;; subtracted from the available space for the box.
;;
;; 2. All children with :auto layout options are measured (the space
;; they are offered is what remains in the box after step 1) and their
;; sizes are summed. This sum is subtracted to determine the space
;; available for exts.
;;
;; 3. The '(n ext) layouts are summed, remaining space is divided by
;; the sum to get the 'slice size'. Each ext widget gets a number of
;; 'slices' corresponding to its n ext multiplier.
;;
;; If the layout options list is not specified when measuring, or
;; there are fewer layout options than child controls, the layout
;; options are filled with '(1 ext) items.

(defclass box (container orientable)
  ((space-between-cells :accessor space-between-cells :initarg :space-between-cells :initform 0)
   (layout-options :accessor layout-options :initarg :layout-options :initform nil)
   (slice-size :accessor slice-size :initarg :slice-size :initform nil)))

(declaim (optimize (debug 3)))

(defun fill-in-layout-options (box)
  (let* ((children-count (length (children box)))
         (layout-options-count (length (layout-options box))))
    (when (< layout-options-count children-count)
      (setf (layout-options box)
            (append (layout-options box)
                    (loop
                       for i from 1 to (- children-count layout-options-count)
                       collect '(1 :ext)))))))

(defun f. (f1 f2)
  (lambda (x)
    (funcall f1 (funcall f2 x))))

(defmethod measure ((object box) available-width available-height)
  (fill-in-layout-options object)
  (let* ((total-spacing (* (1- (length (children object)))
                           (space-between-cells object)))
         (space-left (- (ifhorizontal object available-width available-height)
                        total-spacing))
         (sum-n-ext 0)
         (allocated-space 0))
    ;; Measure pass 1 - measure the pxs and autos while we have space.
    (loop
       for lo in (layout-options object)
       for child in (children object)
       do (progn
            (when (and (> space-left 0)
                       (or (eq :auto lo)
                           (and (consp lo) (eq :px (second lo)))))
              (let (space-increment)
                (cond ((eq :auto lo)
                       (measure child
                                (ifhorizontal object space-left available-width)
                                (ifhorizontal object available-height space-left))
                       (setf space-increment (ifhorizontal object
                                                           (measured-width child)
                                                           (measured-height child))))
                      ((and (consp lo) (eq :px (second lo)))
                       (measure child
                                (ifhorizontal object (first lo) available-width)
                                (ifhorizontal object available-height (first lo)))
                       (setf space-increment (first lo))))
                (decf space-left space-increment)
                (incf allocated-space space-increment)))
            (when (and (consp lo) (eq :ext (second lo)))
              (incf sum-n-ext (first lo)))))
    (when (< space-left 0)
      (setf space-left 0))
    (if (> sum-n-ext 0)
        (setf (slice-size object) (truncate (/ space-left sum-n-ext)))
        (setf (slice-size object) 0))
    ;; Measure pass 2 - calculate the slice in the remaining space and
    ;; measure the exts.
    (loop
       for lo in (layout-options object)
       for child in (children object)
       do (when (and (consp lo)
                     (eq :ext (second lo)))
            (measure child
                     (ifhorizontal object
                                   (* (first lo) (slice-size object))
                                   available-width)
                     (ifhorizontal object
                                   available-height
                                   (* (first lo) (slice-size object))))
            (incf allocated-space (* (first lo) (slice-size object)))))
    (ifhorizontal object
                  (call-next-method object
                                    (+ total-spacing allocated-space)
                                    (apply #'max (mapcar #'measured-height
                                                         (children object))))
                  (call-next-method object
                                    (apply #'max (mapcar #'measured-width
                                                         (children object)))
                                    (+ total-spacing allocated-space)))))

(defmethod layout ((object box) left top width height)
  (let ((running (ifhorizontal object left top)))
    (loop
       for lo in (layout-options object)
       for child in (children object)
       do (progn
            (cond ((eq :auto lo)
                   (ifhorizontal object
                                 (layout child
                                         running top
                                         (measured-width child) height)
                                 (layout child
                                         left running
                                         width (measured-height child)))
                   (incf running (ifhorizontal object
                                               (+ (measured-width child)
                                                  (space-between-cells object))
                                               (+ (measured-height child)
                                                  (space-between-cells object)))))
                  ((and (consp lo) (eq :px (second lo)))
                   (ifhorizontal object
                                 (layout child running top (first lo) height)
                                 (layout child left running width (first lo)))
                   (incf running (+ (first lo) (space-between-cells object))))
                  ((and (consp lo) (eq :ext (second lo)))
                   (ifhorizontal object
                                 (layout child
                                         running top
                                         (* (first lo) (slice-size object)) height)
                                 (layout child
                                         left running
                                         width (* (first lo) (slice-size object))))
                   (incf running (+ (* (first lo) (slice-size object))
                                    (space-between-cells object))))))))
  (call-next-method object left top width height))

;;; STACK class.

(defclass stack (container)
  ())

(defmethod measure ((object stack) available-width available-height)
  (apply #'call-next-method
         object
         (max-box (mapcar #'(lambda (widget)
                              (measure widget available-width available-height))
                          (children object)))))

(defmethod layout ((object stack) left top width height)
  (mapc #'(lambda (widget)
            (layout widget left top (measured-width object) (measured-height object)))
        (children object))
  (call-next-method object left top width height))

;;; CONTAINER1 class.

(defclass container1 (widget)
  ((child :accessor child :initarg :child :initform nil)))

(defmethod initialize-instance :after ((instance container1) &rest initargs)
  (declare (ignore initargs))
  (setf (parent (child instance)) instance))

(defmethod paint-order-walk ((object container1) callback)
  (when (funcall callback object)
    (paint-order-walk (child object) callback)))

(defmethod (setf child) :after (value (instance container1))
  (setf (parent value) instance))

;;; GRID class.

(defclass grid (container orientable)
  ((column-layout-options :accessor column-layout-options
                          :initarg :column-layout-options
                          :initform nil)
   (row-layout-options :accessor row-layout-options
                       :initarg :row-layout-options
                       :initform nil)
   (children-locations :accessor children-locations
                       :initarg :children-locations
                       :initform nil)
   (children-descriptions :accessor children-descriptions
                          :initarg :children-descriptions
                          :initform nil)

   (column-slice-size :accessor column-slice-size
                      :initarg :column-slice-size
                      :initform nil)
   (row-slice-size :accessor row-slice-size
                   :initarg :row-slice-size
                   :initform nil)))

(defmethod initialize-instance :after ((instance grid) &rest initargs)
  (declare (ignore initargs))
  (apply-children-descriptions instance (children-descriptions instance) 0 0))

(defun apply-children-descriptions (instance descriptions column-offset row-offset)
  (mapc (lambda (description)
          (cond ((eq :columns (first description))
                 (loop
                    for children in (rest description)
                    for column = 0 then (1+ column)
                    do (add-column instance children column column-offset row-offset)))
                ((eq :rows (first description))
                 (loop
                    for children in (rest description)
                    for row = 0 then (1+ row)
                    do (add-row instance children row column-offset row-offset)))
                ((eq :offset (first description))
                 (apply-children-descriptions instance
                                              (nthcdr 3 description)
                                              (+ column-offset (second description))
                                              (+ row-offset (third description))))))
        descriptions))

(defun add-column (grid children column column-offset row-offset)
  (loop
     for child in children
     for row = 0 then (1+ row)
     do (add-cell grid
                  (+ column column-offset)
                  (+ row row-offset)
                  child)))

(defun add-row (grid children row column-offset row-offset)
  (loop
     for child in children
     for column = 0 then (1+ column)
     do (add-cell grid
                  (+ column column-offset)
                  (+ row row-offset)
                  child)))

(defun add-cell (grid column row child)
  (push child (children grid))
  (push (list column row) (children-locations grid)))

(defmethod measure ((object grid) available-width available-height)
  (let ((column-count (get-column-count object))
        (row-count (get-row-count object)))
    (if (> column-count 0)
        (setf (column-slice-size object)
              (truncate (/ available-width column-count)))
        0)
    (if (> row-count 0)
        (setf (row-slice-size object)
              (truncate (/ available-width row-count)))
        0)
    (dotimes (column column-count)
      (dotimes (row row-count)
        (aif (get-child-at object column row)
             (measure it (column-slice-size object) (row-slice-size object))))))
  (call-next-method object available-width available-height))

(defun get-column-count (grid)
  (1+
   (apply #'max (mapcar #'first (children-locations grid)))))

(defun get-row-count (grid)
  (1+
   (apply #'max (mapcar #'second (children-locations grid)))))

(defun get-child-at (object column row)
  (let (result)
    (loop
       for child in (children object)
       for location in (children-locations object)
       when (and (= column (first location))
                 (= row (second location)))
       do (setf result child)
       until result)
    result))

(defmethod layout ((object grid) left top width height)
  (let ((column-count (get-column-count object))
        (row-count (get-row-count object)))
    (dotimes (column column-count)
      (dotimes (row row-count)
        (aif (get-child-at object column row)
             (layout it
                     (* column (column-slice-size object))
                     (* row (row-slice-size object))
                     (column-slice-size object)
                     (row-slice-size object))))))
  (call-next-method object left top width height))

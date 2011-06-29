
(in-package :scenic)

;;; SCENE class.

(declaim (optimize (debug 3)))

(defclass scene ()
  ((widget :accessor widget :initarg :widget :initform nil)
   (width :accessor width :initarg :width :initform 1024)
   (height :accessor height :initarg :height :initform 768)
   (last-widget-chain :accessor last-widget-chain :initarg :last-widget-chain :initform nil)
   (mouse-captors :accessor mouse-captors :initarg :mouse-captors :initform nil)
   (dirty :accessor dirty :initarg :dirty :initform t)
   (dirty-list :accessor dirty-list :initarg :dirty-list :initform nil)
   (layedout :accessor layedout :initarg :layedout :initform nil)
   (rectangle-to-redraw :accessor rectangle-to-redraw :initarg :rectangle-to-redraw :initform nil)
   (sdl-surface :accessor sdl-surface :initarg :sdl-surface :initform nil)
   (focusables :accessor focusables :initarg :focusables :initform nil)
   (focused-index :accessor focused-index :initarg :focused-index :initform nil)))

(defun invalidate-scene (scene)
  (setf (dirty scene) t)
  (setf (dirty-list scene) nil))

(defun get-scene (widget)
  (if (eql (type-of widget) 'scene)
      widget
      (if (and widget (parent widget))
          (get-scene (parent widget)))))

(defun capture-mouse (widget)
  (let ((scene (get-scene widget)))
    (if (not (member widget (mouse-captors scene)))
        (push widget (mouse-captors scene)))))

(defun release-mouse (widget)
  (let ((scene (get-scene widget)))
    (setf (mouse-captors scene)
          (remove widget (mouse-captors scene)))))

(defun invalidate (widget)
  (bwhen (scene (get-scene widget))
    (setf (dirty scene) t)
    (push widget (dirty-list scene))))

(defun widget-paint-member (object list)
  (cond ((null list)
         nil)
        ((let ((head (first list)))
           (or (eq object head)
               (and (paint-order-number object)
                    (> (paint-order-number object)
                       (paint-order-number head))
                    (and (affected-rect object)
                         (affected-rect head)
                         (rect-intersect (affected-rect object)
                                         (affected-rect head))))))
         t)
        (t (widget-paint-member object (rest list)))))

(defun visible-bounding-box (widget)
  (with-slots (affected-rect) widget
    (list (left affected-rect)
          (top affected-rect)
          (right affected-rect)
          (bottom affected-rect))))

(defun common-bounding-box (bbox1 bbox2)
  (list (min (first bbox1) (first bbox2))
        (min (second bbox1) (second bbox2))
        (max (third bbox1) (third bbox2))
        (max (fourth bbox1) (fourth bbox2))))

(defclass rect ()
  ((left :accessor left :initarg :left :initform 0)
   (top :accessor top :initarg :top :initform 0)
   (width :accessor width :initarg :width :initform 0)
   (height :accessor height :initarg :height :initform 0)))

(gen-print-object rect (left top width height))

(defun right (rect)
  (1- (+ (left rect) (width rect))))

(defun bottom (rect)
  (1- (+ (top rect) (height rect))))

(defclass point ()
  ((x :accessor x :initarg :x :initform 0)
   (y :accessor y :initarg :y :initform 0)))

(gen-print-object point (x y))

(defun corners-of-rectangle (rect)
  (with-slots (left top width height) rect
    (list (make-instance 'point :x left :y top)
          (make-instance 'point :x (1- (+ left width)) :y top)
          (make-instance 'point :x left :y (1- (+ top height)))
          (make-instance 'point :x (1- (+ left width)) :y (1- (+ top height))))))

(defun in-rect (x y rect)
  (with-slots (left top width height) rect
    (and (<= left x)
         (< x (+ left width))
         (<= top y)
         (< y (+ top height)))))

(defun rect-intersect (rect1 rect2)
  (labels ((rect-intersection ()
             (let ((left (max (left rect1) (left rect2)))
                   (top (max(top rect1) (top rect2)))
                   (right (min (right rect1) (right rect2)))
                   (bottom (min (bottom rect1) (bottom rect2))))
               (make-instance 'rect
                              :left left
                              :top top
                              :width (1+ (- right left))
                              :height (1+ (- bottom top)))))
           (intersect-p ()
             (or (dolist (corner (corners-of-rectangle rect1))
                   (if (in-rect (x corner) (y corner) rect2)
                       (return t)))
                 (dolist (corner (corners-of-rectangle rect2))
                   (if (in-rect (x corner) (y corner) rect1)
                       (return t))))))
    (when (intersect-p)
      (rect-intersection))))

(defun layout-rect (widget)
  (make-instance 'rect
                 :left (layout-left widget)
                 :top (layout-top widget)
                 :width (layout-width widget)
                 :height (layout-height widget)))

(defun intersects-clip-rect (widget offset-x offset-y clip-rect)
  (let ((widget-rect (layout-rect widget)))
    (decf (left widget-rect) offset-x)
    (decf (top widget-rect) offset-y)
    (if (null clip-rect)
        t
        (rect-intersect widget-rect clip-rect))))

(defun visible-rect (widget offset-x offset-y clip-rect)
  (let ((visible-rect (layout-rect widget)))
    (decf (left visible-rect) offset-x)
    (decf (top visible-rect) offset-y)
    (if (null clip-rect)
        visible-rect
        (rect-intersect visible-rect clip-rect))))

(defun assign-paint-numbers (root-widget)
  (let ((number 0)
        (offset-x 0)
        (offset-y 0)
        (clip-rect-stack nil)
        (clipper-stack nil))
    (paint-order-walk root-widget
                      (lambda (object)
                        (setf (paint-order-number object) nil)
                        (setf (affected-rect object)
                              (visible-rect object
                                            offset-x offset-y
                                            (car clip-rect-stack)))
                        (when (affected-rect object)
                          (setf (paint-order-number object) number)
                          (incf number)
                          (when (clips-content object)
                            (push (affected-rect object)
                                  clip-rect-stack)
                            (push object clipper-stack))
                          (when (typep object 'scroll-view)
                            (incf offset-x (horizontal-offset object))
                            (incf offset-y (vertical-offset object)))
                          t))
                      :after-callback (lambda (object)
                                        (when (and (eq object (car clipper-stack))
                                                   (typep object 'scroll-view))
                                          (incf offset-x (horizontal-offset object))
                                          (incf offset-y (vertical-offset object)))
                                        (when (and (eq object (car clipper-stack))
                                                   (clips-content object))
                                          (pop clipper-stack)
                                          (pop clip-rect-stack))))))

(defun paint-scene (scene)
  (if (null (dirty-list scene))
      (paint-order-walk (widget scene)
                        (lambda (object)
                          (paint object)
                          t)
                        :after-callback (lambda (object)
                                          (after-paint object)))
      (progn
        (assign-paint-numbers (widget scene))
        (paint-order-walk (widget scene)
                          (lambda (object)
                            (cond ((widget-paint-member object (dirty-list scene))
                                   (paint object)
                                   (push object (dirty-list scene)))
                                  ((typep object 'scroll-view)
                                   (paint object)))
                            t)
                          :after-callback (lambda (object)
                                            (cond ((widget-paint-member object
                                                                        (dirty-list scene))
                                                   (after-paint object))
                                                  ((typep object 'scroll-view)
                                                   (after-paint object)))))
        (setf (rectangle-to-redraw scene)
              (reduce #'common-bounding-box
                      (mapcar #'visible-bounding-box (dirty-list scene))))))
  (setf (dirty-list scene) nil))

(defmethod measure ((object scene) available-width available-height)
  (measure (widget object) available-width available-height))

(defmethod layout ((object scene) left top width height)
  (layout (widget object) left top width height))

(defun hit-test (widget x y)
  (let (result scroll-views)
    (paint-order-walk widget
                      (lambda (object)
                        (when (in-widget x y object)
                          (when (typep object 'scroll-view)
                            (push object scroll-views)
                            (incf x (horizontal-offset object))
                            (incf y (vertical-offset object)))
                          (setf result object)))
                      :after-callback (lambda (object)
                                        (when (eq (car scroll-views) object)
                                          (pop scroll-views)
                                          (decf x (horizontal-offset object))
                                          (decf y (vertical-offset object)))))
    result))

(defun cascade-then-bubble (widget-chain event event-arg)
  (dolist (widget widget-chain)
    (when (not (handled event-arg))
      (on-event widget event event-arg :cascade))
    (when (typep widget 'scroll-view)
      (adjust-event-coordinates event-arg
                                (horizontal-offset widget)
                                (vertical-offset widget))))
  (dolist (widget (reverse widget-chain))
    (when (not (handled event-arg))
      (on-event widget event event-arg :bubble))
    (when (typep widget 'scroll-view)
      (adjust-event-coordinates event-arg
                                (- (horizontal-offset widget))
                                (- (vertical-offset widget))))))

(defun branch-diff (branch1 branch2)
  (cond ((null branch1) nil)
        ((null branch2) branch1)
        ((eq (first branch1) (first branch2)) (branch-diff (rest branch1)
                                                           (rest branch2)))
        (t branch1)))

(defun calculate-mouse-leave (old-chain new-chain)
  (branch-diff old-chain new-chain))

(defun calculate-mouse-enter (old-chain new-chain)
  (branch-diff new-chain old-chain))

(defun scene-handle-mouse-captors (scene event mouse-event)
  (dolist (captor (mouse-captors scene))
    (setf (handled mouse-event) nil)
    (on-event captor event mouse-event nil)))

(defun scene-on-mouse-move (scene mouse-event)
  (let* ((widget-chain (get-widget-chain (list (hit-test (widget scene)
                                                         (mouse-x mouse-event)
                                                         (mouse-y mouse-event)))))
         (mouse-leave-widgets (calculate-mouse-leave (last-widget-chain scene)
                                                     widget-chain))
         (mouse-enter-widgets (calculate-mouse-enter (last-widget-chain scene)
                                                     widget-chain)))
    (setf (last-widget-chain scene) widget-chain)
    (cascade-then-bubble mouse-leave-widgets :mouse-leave mouse-event)
    (setf (handled mouse-event) nil)
    (cascade-then-bubble mouse-enter-widgets :mouse-enter mouse-event)
    (setf (handled mouse-event) nil)
    (cascade-then-bubble widget-chain :mouse-move mouse-event)
    (setf (handled mouse-event) nil)
    (scene-handle-mouse-captors scene :mouse-move mouse-event)))

(defun scene-on-mouse-button (scene event mouse-event)
  (let ((widget-chain (get-widget-chain (list (hit-test (widget scene)
                                                        (mouse-x mouse-event)
                                                        (mouse-y mouse-event))))))
    (cascade-then-bubble widget-chain event mouse-event)
    (scene-handle-mouse-captors scene event mouse-event)))

(defun set-focus (scene focus &optional (invalidate t))
  (when (and (< (focused-index scene) (length (focusables scene)))
             (not (eq (has-focus (aref (focusables scene) (focused-index scene)))
                      focus)))
    (setf (has-focus (aref (focusables scene) (focused-index scene)))
          focus)
    (when invalidate
      (invalidate (aref (focusables scene) (focused-index scene))))))

(defun focus-widget (scene widget)
  (let ((widget-pos (position widget (focusables scene))))
    (when (and (focusable widget) widget-pos)
      (cond ((focused-widget scene)
             (unless (eq (focused-widget scene) widget)
               (set-focus scene nil)
               (setf (focused-index scene) widget-pos)
               (set-focus scene t)))
            (t
             (setf (focused-index scene) widget-pos)
             (set-focus scene t))))))

(defun calculate-focusables (scene)
  (when (focusables scene)
    (error "TODO: recalculate focusables, keep the focus on the currently focused object."))
  (let (result)
    (paint-order-walk (widget scene)
                      (lambda (widget)
                        (when (focusable widget)
                          (push widget result))
                        t))
    (setf (focusables scene) (coerce (nreverse result) 'vector))
    (setf (focused-index scene) 0)
    (set-focus scene t nil)))

(defun focused-widget (scene)
  (when (< (focused-index scene) (length (focusables scene)))
    (let ((result (aref (focusables scene) (focused-index scene))))
      (if (has-focus result) result))))

(defun focus-next (scene)
  (set-focus scene nil)
  (incf (focused-index scene))
  (when (= (focused-index scene) (length (focusables scene)))
    (setf (focused-index scene) 0))
  (set-focus scene t))

(defun focus-previous (scene)
  (set-focus scene nil)
  (decf (focused-index scene))
  (when (< (focused-index scene) 0)
    (setf (focused-index scene) (max (1- (length (focusables scene)))
                                     0)))
  (set-focus scene t))

(defun shifted (modifiers)
  (if (consp modifiers)
      (cond ((or (eq (car modifiers) :mod-lshift)
                 (eq (car modifiers) :mod-rshift))
             t)
            (t (shifted (cdr modifiers))))))

(defun scene-on-key (scene event-kind key-event)
  (aif (focused-widget scene)
       (let ((widget-chain (get-widget-chain (list it))))
         (cascade-then-bubble widget-chain event-kind key-event)
         (when (not (handled key-event))
           (when (and (eq :key-down event-kind)
                      (eq (key key-event) :tab))
             (setf (handled key-event) t)
             (if (shifted (modifiers key-event))
                 (focus-previous scene)
                 (focus-next scene)))))))

(defmethod initialize-instance :after ((instance scene) &rest initargs)
  (declare (ignore initargs))
  (setf (parent (widget instance)) instance))

(defun measure-layout (scene)
  (unless (layedout scene)
    (measure scene (width scene) (height scene))
    (layout scene 0 0 (width scene) (height scene))
    (setf (layedout scene) t)))

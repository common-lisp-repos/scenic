
(in-package :scenic-test)

(declaim (optimize debug safety))

(defstruct auto-test name scene-function scene-session-file description-file)

(defvar *tests*)

(setf *tests*
      (list (make-auto-test :name "background-clear"
                            :scene-function #'background-clear
                            :scene-session-file "test-data/background-clear.gz"
                            :description-file "test-data/background-clear.txt")
            (make-auto-test :name "colored-rectangles"
                            :scene-function #'colored-rectangles
                            :scene-session-file "test-data/colored-rectangles.gz"
                            :description-file "test-data/colored-rectangles.txt")
            (make-auto-test :name "hello-world"
                            :scene-function #'hello-world
                            :scene-session-file "test-data/hello-world.gz"
                            :description-file "test-data/hello-world.txt")
            (make-auto-test :name "buttons"
                            :scene-function #'buttons
                            :scene-session-file "test-data/buttons.gz"
                            :description-file "test-data/buttons.txt")
            (make-auto-test :name "slider"
                            :scene-function #'slider
                            :scene-session-file "test-data/slider.gz"
                            :description-file "test-data/slider.txt")
            (make-auto-test :name "scrollbars"
                            :scene-function #'scrollbars
                            :scene-session-file "test-data/scrollbars.gz"
                            :description-file "test-data/scrollbars.txt")
            (make-auto-test :name "icon"
                            :scene-function #'icon
                            :scene-session-file "test-data/icon.gz"
                            :description-file "test-data/icon.txt")
            (make-auto-test :name "text-baseline-alignment"
                            :scene-function #'text-baseline-alignment
                            :scene-session-file "test-data/text-baseline-alignment.gz"
                            :description-file "test-data/text-baseline-alignment.txt")
            (make-auto-test :name "vertical-box-layout-options"
                            :scene-function #'vertical-box-layout-options
                            :scene-session-file "test-data/vertical-box-layout-options.gz"
                            :description-file "test-data/vertical-box-layout-options.txt")
            (make-auto-test :name "horizontal-box-layout-options"
                            :scene-function #'horizontal-box-layout-options
                            :scene-session-file "test-data/horizontal-box-layout-options.gz"
                            :description-file "test-data/horizontal-box-layout-options.txt")
            (make-auto-test :name "grid-basic"
                            :scene-function #'grid-basic
                            :scene-session-file "test-data/grid-basic.gz"
                            :description-file "test-data/grid-basic.txt")
            (make-auto-test :name "grid-offset"
                            :scene-function #'grid-offset
                            :scene-session-file "test-data/grid-offset.gz"
                            :description-file "test-data/grid-offset.txt")
            (make-auto-test :name "grid-spans"
                            :scene-function #'grid-spans
                            :scene-session-file "test-data/grid-spans.gz"
                            :description-file "test-data/grid-spans.txt")
            (make-auto-test :name "grid-layout-options"
                            :scene-function #'grid-layout-options
                            :scene-session-file "test-data/grid-layout-options.gz"
                            :description-file "test-data/grid-layout-options.txt")
            (make-auto-test :name "grid-layout-options-2"
                            :scene-function #'grid-layout-options-2
                            :scene-session-file "test-data/grid-layout-options-2.gz"
                            :description-file "test-data/grid-layout-options.txt")
            (make-auto-test :name "grid-layout-options-3"
                            :scene-function #'grid-layout-options-3
                            :scene-session-file "test-data/grid-layout-options-3.gz"
                            :description-file "test-data/grid-layout-options.txt")
            (make-auto-test :name "aligner-1"
                            :scene-function #'aligner-1
                            :scene-session-file "test-data/aligner-1.gz"
                            :description-file "test-data/aligner-1.txt")
            (make-auto-test :name "clipper-1"
                            :scene-function #'clipper-1
                            :scene-session-file "test-data/clipper-1.gz"
                            :description-file "test-data/clipper-1.txt")
            (make-auto-test :name "glass-1"
                            :scene-function #'glass-1
                            :scene-session-file "test-data/glass-1.gz"
                            :description-file "test-data/glass-1.txt")
            (make-auto-test :name "henchman-1"
                            :scene-function #'henchman-1
                            :scene-session-file "test-data/henchman-1.gz"
                            :description-file "test-data/henchman-1.txt")
            (make-auto-test :name "henchman-glass"
                            :scene-function #'henchman-glass
                            :scene-session-file "test-data/henchman-glass.gz"
                            :description-file "test-data/henchman-glass.txt")
            (make-auto-test :name "scroll-view-1"
                            :scene-function #'scroll-view-1
                            :scene-session-file "test-data/scroll-view-1.gz"
                            :description-file "test-data/scroll-view-1.txt")
            (make-auto-test :name "textbox-1"
                            :scene-function #'textbox-1
                            :scene-session-file "test-data/textbox-1.gz"
                            :description-file "test-data/textbox-1.txt")
            (make-auto-test :name "textbox-2"
                            :scene-function #'textbox-2
                            :scene-session-file "test-data/textbox-2.gz"
                            :description-file "test-data/textbox-2.txt")
            (make-auto-test :name "scroll-view-hittest"
                            :scene-function #'scroll-view-hittest
                            :scene-session-file "test-data/scroll-view-hittest.gz"
                            :description-file "test-data/scroll-view-hittest.txt")
            (make-auto-test :name "scroll-view-mouse-adjust"
                            :scene-function #'scroll-view-mouse-adjust
                            :scene-session-file "test-data/scroll-view-mouse-adjust.gz"
                            :description-file "test-data/scroll-view-mouse-adjust.txt")
            (make-auto-test :name "checkbox-1"
                            :scene-function #'checkbox-1
                            :scene-session-file "test-data/checkbox-1.gz"
                            :description-file "test-data/checkbox-1.txt")
            (make-auto-test :name "radio-button-1"
                            :scene-function #'radio-button-1
                            :scene-session-file "test-data/radio-button-1.gz"
                            :description-file "test-data/radio-button-1.txt")
            (make-auto-test :name "simple-boxes"
                            :scene-function #'simple-boxes
                            :scene-session-file "test-data/simple-boxes.gz"
                            :description-file "test-data/simple-boxes.txt")
            (make-auto-test :name "scroll-view-2"
                            :scene-function #'scroll-view-2
                            :scene-session-file "test-data/scroll-view-2.gz"
                            :description-file "test-data/scroll-view-2.txt")
            (make-auto-test :name "add-task"
                            :scene-function #'add-task
                            :scene-session-file "test-data/add-task.gz"
                            :description-file "test-data/add-task.txt")
            (make-auto-test :name "add-task-with-thread"
                            :scene-function #'add-task-with-thread
                            :scene-session-file "test-data/add-task-with-thread.gz"
                            :description-file "test-data/add-task-with-thread.txt")))

(defun find-test (name)
  (find name *tests* :test #'string-equal :key #'auto-test-name))

(defun store-test-information (test session-record)
  (scenic:write-gzipped-resource (auto-test-scene-session-file test)
                                 (let ((*package* (find-package "KEYWORD")))
                                   (format nil "~s" session-record))))

(defun record-auto-test-session (test-name)
  (let ((test (find-test test-name)))
    (unless test
      (error (format nil "Can't find test ~a!" test-name)))
    (format t "~a~%" (scenic:read-resource (auto-test-description-file test)))
    (let ((*manual-test-run* t)
          (scenic::*text-info-auto-test* t))
      (let ((session-record (test-scene (funcall (auto-test-scene-function test))
                                        t)))
        (when (yes-no-query "Did the test pass?")
          (store-test-information test session-record))))))

(defun run-auto-test (test)
  (let* ((*manual-test-run* nil)
         (scenic::*text-info-auto-test* t))
    (handler-case
        (let ((session-record
               (with-input-from-string
                   (str (scenic:read-gzipped-resource (auto-test-scene-session-file test)))
                 (read str))))
          (scenic:replay-scene-session
           (funcall (auto-test-scene-function test))
           session-record))
      (simple-condition (ex) (values nil
                                     (apply #'format nil
                                            (simple-condition-format-control ex)
                                            (simple-condition-format-arguments ex))))
      (t () (values nil (trivial-backtrace:backtrace-string))))))

(defun run-auto-tests ()
  (let ((total-tests 0)
        (failed-tests 0))
    (mapc (lambda (test)
            (format t "Running test ~40a" (format nil "'~a':" (auto-test-name test)))
            (incf total-tests)
            (multiple-value-bind (result reason)
                (run-auto-test test)
              (format t "~a~%" (if result "PASS" (progn
                                                   (incf failed-tests)
                                                   (format nil "~a~%~a~%" "FAIL" reason))))))
          *tests*)
    (terpri)
    (if (= 0 failed-tests)
        (format t "~a tests ran. ALL TESTS PASSED!~%" total-tests)
        (format t "~a tests ran. ~a tests failed. SOME TESTS FAILED!~%" total-tests failed-tests))
    nil))


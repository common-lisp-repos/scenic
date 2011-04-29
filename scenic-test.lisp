
(in-package :scenic-test)

(defun make-scene ()
  (let (text1 text2 text3 button scn)
    (setf scn
          (scene 800 800
                 (stk
                   (bg (list 1.0 1.0 1.0)
                       (flr))
                   (upad 3
                     (bg (list 0.9 0.9 0.9)
                         (vbox 10
                           (border (list 0.3 0.3 0.3)
                                   1
                                   (bg (list 1.0 0.3 0.3)
                                       (spc 100 100)))
                           (border (list 0.3 0.3 0.3)
                                   1
                                   (bg (list 0.3 1.0 0.3)
                                       (spc 100 100)))
                           (border (list 0.3 0.3 0.3)
                                   1
                                   (bg (list 0.3 0.3 1.0)
                                       (spc 100 100)))
                           (hbox 10
                             (border (list 0.3 0.3 0.3)
                                     1
                                     (bg (list 0.7 0.7 0.7)
                                         (upad 3
                                           (setf text1
                                                 (lbl "Ana are pere." :size 20 :slant :italic)))))
                             (border (list 0.3 0.3 0.3)
                                     1
                                     (bg (list 0.7 0.7 0.7)
                                         (upad 3
                                           (setf text2
                                                 (lbl "Petre n-are mere."
                                                      :color (list 0.2 0.4 0.6)
                                                      :size 20)))))
                             (border (list 0.3 0.3 0.3)
                                     1
                                     (bg (list 0.7 0.7 0.7)
                                         (upad 3 (setf text3
                                                       (lbl "on." :size 20 :weight :bold))))))
                           (hbox 10
                             (border (list 0 0 0) 1 (setf button (btntxt "Gigel")))
                             (border (list 0 0 0) 1 (toggle "Titel"))
                             (szr (hslider 0 10 1)
                                    :max-width 200
                                    :max-height 20))))))))
    (scenic:add-mouse-move text1
                           (lambda (object event)
                             (format t "text1 move: ~a ~a~%" object event))
                           :bubble)
    (scenic:add-mouse-enter text1
                            (lambda (object event)
                              (format t "text1 enter: ~a ~a~%" object event))
                            :bubble)
    (scenic:add-mouse-leave text1
                            (lambda (object event)
                              (format t "text1 leave: ~a ~a~%" object event))
                            :bubble)
    (scenic:add-mouse-move text2
                           (lambda (object event)
                             (format t "text2 move: ~a ~a~%" object event))
                           :bubble)
    (scenic:add-mouse-move text3
                           (lambda (object event)
                             (format t "text3 move: ~a ~a~%" object event))
                           :cascade)
    (scenic:add-mouse-move button
                           (lambda (object event)
                             (format t "button move: ~a ~a~%" object event))
                           :cascade)
    (scenic:add-mouse-enter button
                            (lambda (object event)
                              (format t "button enter: ~a ~a~%" object event))
                            :cascade)
    (scenic:add-mouse-leave button
                            (lambda (object event)
                              (format t "button leave: ~a ~a~%" object event))
                            :cascade)
    (scenic:add-mouse-button-down button
                                  (lambda (object event)
                                    (format t "button down: ~a ~a~%" object event))
                                  :cascade)
    (scenic:add-mouse-button-up button
                                (lambda (object event)
                                  (format t "button up: ~a ~a~%" object event))
                                :cascade)
    (scenic:add-click-handler button
                              (lambda (object event)
                                (declare (ignore object event))
                                (format t "button click~%")))
    scn))



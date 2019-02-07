#lang racket
(provide draw
         draw-text)

(require "tree-structs.rkt"
         2htdp/image)

(define (draw-text s [col 'black])
  (beside (whitespace 2) (txt s col) (whitespace 2)))

(define (txt x col [size 20])
  (text/font x
             size
             col
             #f
             'roman
             'normal
             'normal
             #f))

(define hspace 20)
(define vspace 20)
(define vspace2 3)

(define (whitespace w)
  (rectangle w 0 'solid (color 0 0 0 0)))

(define (place-mid img y scene)
  (define x (/ (- (image-width scene) (image-width img)) 2))
  (place-image/align img x y 'left 'top scene))

(define (besidel l)
  (match l
    ['() (whitespace 10)]
    [(list x) x]
    [l (apply beside/align 'top l)]))

(define (add-lines start-y stop-y width widths scene)
  (define mid-x (/ (image-width scene) 2))
  (define w-num (length widths))
  (define h (if (< w-num 2) 0 (/ width (- w-num 1))))
  (define first-x
    (if (< w-num 2)
        (/ (image-width scene) 2)
        (- (/ (image-width scene) 2) (/ width 2))))
  
  (define-values (res a b)
    (for/fold ([img scene] [start-x first-x] [stop-x 0])
              ([w widths])
      (values (scene+line img start-x start-y (+ stop-x (/ w 2)) stop-y 'black)
              (+ start-x h)
              (+ stop-x w hspace))))
  res)

(define (draw t)
  (match t
    [(tree t-img children) 
     (define c-imgs (map draw children))
     (define c-img (besidel (add-between c-imgs (whitespace hspace))))
     
     (define t-h (image-height t-img))
     
     (define empty (rectangle (max (image-width t-img) (image-width c-img))
                              (+ t-h (image-height c-img) vspace vspace2 vspace2)
                              'solid
                              (color 0 0 0 0)))
     
     (define c-y (+ t-h vspace vspace2 vspace2))
     (define widths (map image-width c-imgs))
     
     (add-lines (+ t-h vspace2)
                (- c-y vspace2)
                (image-width t-img)
                widths
                (place-mid c-img c-y (place-mid t-img 0 empty)))]))


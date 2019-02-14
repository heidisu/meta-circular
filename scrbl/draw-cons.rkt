#lang racket
(provide draw-cons)

(require 2htdp/image
         "draw.rkt")

(define reg-img
  (let ()
    (define i (draw-text " "))
    (define s (image-height i))
    (overlay (rectangle s s 'outline 'black)
             (rectangle s s 'solid 'white))))

(define reg-w (image-width reg-img))
(define reg-w/2 (/ reg-w 2))
(define reg-h (image-height reg-img))
(define reg-h/2 (/ reg-h 2))
(define padding 15)

(define cons-img (beside reg-img reg-img))

(define cons-w (image-width cons-img))
(define cons-h (image-height cons-img))

(struct img (img top-x side-x) #:transparent)

(define (draw-cons-halp c)
  (match c
    [(cons a d)
     (match-define (img a-img a-top-x _) (draw-cons-halp a))
     (match-define (img d-img _ d-side-x) (draw-cons-halp d))
     (define c/a-w (+ (max a-top-x reg-w/2) (max (- (image-width a-img) a-top-x) (* reg-w/2 3))))
     (define scene-w (+ c/a-w padding (image-width d-img)))
     (define scene-h (max (+ reg-h padding (image-height a-img)) (image-height d-img)))
     (define scene (rectangle scene-w scene-h 'solid  (color 0 0 0 0)))
     (define cons-x (max 0 (- a-top-x reg-w/2)))     
     (define scene/c (place-image/align cons-img cons-x 0 'left 'top scene))
     (define a-x (- (+ cons-x reg-w/2) a-top-x))
     (define scene/a (place-image/align a-img a-x (+ reg-h padding) 'left 'top scene/c))
     (define a/l-x (+ a-x a-top-x))
     (define scene/a/l (scene+line scene/a a/l-x reg-h/2 a/l-x (+ reg-h padding) 'black))
     (define d-x (+ c/a-w padding))
     (define scene/d (place-image/align d-img d-x 0 'left 'top scene/a/l))
     (define scene/d/l (scene+line scene/d (+ cons-x (* reg-w/2 3)) reg-h/2 (+ d-x d-side-x) reg-h/2 'black))
     (img scene/d/l (+ cons-x reg-w/2) cons-x)]
    [_ (draw-text-halp c)]))

(define (draw-text-halp x)
  (define i (draw-text (~s x)))
  (img i (/ (image-width i) 2) 0))

(define draw-cons (compose img-img draw-cons-halp))

(module+ main
  (draw-cons '(1 2 (a . b) 3 4)))

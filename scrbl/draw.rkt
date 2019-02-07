#lang racket
(provide draw-text
         whitespace)

(require 2htdp/image)

(define (draw-text s [col 'black])
  (beside (whitespace 2) (txt s col) (whitespace 2)))

(define (txt x col [size 20])
  (text/font x
             size
             col
             #f
             'modern
             'normal
             'normal
             #f))

(define (whitespace w)
  (rectangle w 0 'solid (color 0 0 0 0)))
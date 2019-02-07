#lang racket
(require "draw.rkt"
         "tree-structs.rkt"
         2htdp/image)

(define (s-exp->tree s-exp)
  (match s-exp
    [(list operator operands ...)
     (tree operator (map s-exp->tree operands))]
    [x (tree x '())]))

(define draw-ast (compose draw (tree-map (λ (s) (draw-text (~a s)))) s-exp->tree))
  
(module+ main
  (draw-ast '(+ 1 (+ 1 2))))
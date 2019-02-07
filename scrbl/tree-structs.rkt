#lang racket
(provide (struct-out tree)
         tree-map
         tr)

(struct tree (thing children) #:transparent)

(define (tr t . ts)
  (tree t ts))

(define ((tree-map f) t)
  (match t
    [(tree thing children)
     (tree (f thing) (map (tree-map f) children))]))
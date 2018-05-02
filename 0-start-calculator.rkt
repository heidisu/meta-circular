#lang racket


(define (eval-exp exp)
  (match exp
    [(? number?) exp]
    
    [(list '+ args ...) (apply + (map eval-exp args))]
    
    [(list '- args ...) (apply - (map eval-exp args))]
    
    [(list '* args ...) (apply * (map eval-exp args))]
    
    [(list '/ args ...) (apply * (map eval-exp args))]
    
    [_ (error 'wat (~a exp))]))

(define (evaluate input)
  (eval-exp input))

(define (repl)
  (printf "> ")
  (define input (read))
  (unless (eof-object? input)
    (define output (evaluate input))
    (printf "~a~n" output)
    (repl)))


(module+ test
  (require rackunit)

  (check-equal?
   (evaluate '(+ 1 2))
   3)

  (check-equal?
   (evaluate '(+ 1 2 3))
   6)

  (check-equal?
   (evaluate '(- 2 1))
   1)

  (check-equal?
   (evaluate '(* 2 4))
   8)

  (check-equal?
   (evaluate '(/ 8 2))
   4)

  (check-equal?
   (evaluate '(* 2 (+ 1 (- 4 2))))
   6)

  (check-exn
   exn:fail?
   (λ ()
     (eval '(foo 1 2))))
  )
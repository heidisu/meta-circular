#lang racket

(define (lookup env s)
  (match env    
    [(list (cons name val) rest ...)
     (if (equal? name s)
         val
         (lookup rest s))]
    
    [(list)
     (error 'unknown (~a s))]))

(define primitives
  (list (cons '+ +)
        (cons '- -)
        (cons '/ /)
        (cons '* *)))

(define (eval-application env fun args)
  (apply (eval-exp env fun)
            (map (λ (x) (eval-exp env x)) args)))

(define (eval-exp env exp)
  (match exp
    [(? symbol?) (lookup env exp)]
    [(? number?) exp]
    
    [(list fun args ...) (eval-application env fun args)]
    
    [_ (error 'wat (~a exp))]))

(define (evaluate input)
  (eval-exp primitives input))

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

  (check-equal?
   (lookup (list (cons 'a 1)
                 (cons 'b 2))
           'a)
   1)

  (check-equal?
   (lookup (list (cons 'a 1)
                 (cons 'b 2))
           'b)
   2)

  (check-equal?
   (lookup (list (cons 'a 0)
                 (cons 'a 1)
                 (cons 'b 2))
           'a)
   0)


  (check-exn
   exn:fail?
   (λ ()
     (lookup (list (cons 'a 1)
                   (cons 'b 2))
             'c))
   0)
  )
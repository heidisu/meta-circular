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

(define (extend-environment env names values)
  (append (map cons names values) env))

(define (make-function env parameters body)
  (λ arguments
    (define new-env (extend-environment env parameters arguments))
    (eval-sequence new-env
                   body)))

(define (eval-application env fun args)
  (apply (eval-exp env fun)
            (map (λ (x) (eval-exp env x)) args)))

(define (eval-sequence env terms)
  (match terms
    [(list exp) (eval-exp env exp)]
    
    [(list (list 'define name exp) rest ...)
     (define value (eval-exp env exp))
     (define new-env (extend-environment env (list name)(list value)))
     (eval-sequence new-env rest)]
 
    [(list trm rest ...)
     (eval-exp env trm)
     (eval-sequence env rest)]))

(define (eval-exp env exp)
  (match exp
    [(? symbol?) (lookup env exp)]
    [(? number?) exp]

    [(list 'begin terms ...) (eval-sequence env terms)]
    
    [(list 'λ parameters body ...) (make-function env parameters body)]

    [(list 'lambda parameters body ...) (make-function env parameters body)]

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
  
  (check-equal?
   (extend-environment (list (cons 'd 2) (cons 'e 1))
                       (list 'a 'b 'c)
                       (list 5 4 3))
   (list (cons 'a 5) (cons 'b 4) (cons 'c 3) (cons 'd 2) (cons 'e 1)))

  (check-equal?
   (evaluate
    '(begin
       (define a 2)
       (define b 3)
       (+ a b)))
   5)

  (check-equal?
   (evaluate
    '(begin
       (define a 2)
       (define a 3)
       (+ a a)))
   6)

  (check-equal?
   (evaluate '((λ () (+ 2 3))))
   5)
  
  (check-equal?
   (evaluate '((lambda (x y) (+ x y)) 3 4))
   7)
  
  (check-equal?
   (evaluate
    '((lambda ()
        (define a 2)
        (define b 3)
        (+ a b))))
   5)
  
  (check-equal?
   (evaluate
    '((lambda ()
        (define a 2)
        (define b (lambda (c) (define a 5) (+ a c)))
        (b a))))
   7)
  )
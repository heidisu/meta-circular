#lang racket

(define (lookup env s)
  (match env    
    [(list (cons name val) rest ...)
     (if (equal? name s)
         val
         (lookup rest s))]
    
    [(list)
     (error 'unknown (~a s))]))

(define (primitive fun)
  (λ (continue . args)
    (continue (apply fun args))))

(define primitives
  (list (cons '+ (primitive +))
        (cons '- (primitive -))
        (cons '/ (primitive /))
        (cons '* (primitive *))
        (cons '= (primitive =))
        (cons '< (primitive <))
        (cons '<= (primitive <=))
        (cons '> (primitive >))
        (cons '>= (primitive >=))))

(define (extend-environment env names values)
  (append (map cons names values) env))

(define (make-function env parameters body)
  (λ (continue . arguments)
    (define new-env (extend-environment env parameters arguments))
    (eval-sequence new-env
                   continue
                   body)))

(define (eval-arguments env continue args)
  (match args
    ['() (continue '())]
    [(list arg rest ...)
     (eval-exp env
               (λ (arg-val)
                 (eval-arguments env
                                 (λ (rest-val)
                                   (continue (cons arg-val rest-val)))
                                 rest))
               arg)]))

(define (eval-application env continue fun args)
  (eval-exp env
            (λ (fun-val)
              (eval-arguments env
                              (λ (args-val)
                                (apply fun-val continue args-val))
                              args))
            fun))

(define (eval-sequence env continue terms)
  (match terms
    [(list exp) (eval-exp env continue exp)]
    
    [(list (list 'define name exp) rest ...)
     (eval-exp env
               (λ (value)
                 (define new-env (extend-environment env (list name)(list value)))
                 (eval-sequence new-env continue rest))
               exp)]
 
    [(list trm rest ...)
     (eval-exp env
               (λ (ignored)
                 (eval-sequence env continue rest))
               trm)]))

(define (eval-exp env continue exp)
  (match exp
    [(? symbol?) (continue (lookup env exp))]
    [(? number?) (continue exp)]
    [(? boolean?) (continue exp)]
    
    [(list 'if exp then else)
     (eval-exp env
               (λ (value) (eval-exp env continue (if value then else)))
               exp)]

    [(list 'begin terms ...) (eval-sequence env continue terms)]
    
    [(list 'λ parameters body ...) (continue (make-function env parameters body))]

    [(list 'lambda parameters body ...) (continue (make-function env parameters body))]

    [(list fun args ...) (eval-application env continue fun args)]
    
    [_ (error 'wat (~a exp))]))

(define (evaluate input)
  (eval-exp primitives
            identity
            input))

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

  (check-equal?
   (evaluate '(if #f 3 5))
   5)

  (check-equal?
   (evaluate '(if (< 8 4) 1 0))
   0)

  (check-equal?
   (evaluate '((λ (a b)
                 (if (> a (+ b b)) 3 6))
               9 1))
   3)

  (check-equal?
   (evaluate '((λ (a b)
                 (if (> a (+ b b)) 3 6))
               9 5))
   6)
  )
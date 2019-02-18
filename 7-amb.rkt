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
  (λ (continue fail . args)
    (continue fail (apply fun args))))

(define primitives
  (list (cons '+ (primitive +))
        (cons '- (primitive -))
        (cons '/ (primitive /))
        (cons '* (primitive *))
        (cons '= (primitive =))
        (cons '< (primitive <))
        (cons '<= (primitive <=))
        (cons '> (primitive >))
        (cons '>= (primitive >=))
        (cons 'list (primitive list))))

(define (extend-environment env names values)
  (append (map cons names values) env))

(define (make-function env parameters body)
  (λ (continue fail . arguments)
    (define new-env (extend-environment env parameters arguments))
    (eval-sequence new-env
                   continue
                   fail
                   body)))

(define (eval-arguments env continue fail args)
  (match args
    ['() (continue fail '())]
    [(list arg rest ...)
     (eval-exp env
               (λ (fail2 arg-val)
                 (eval-arguments env
                                 (λ (fail3 rest-val)
                                   (continue fail3 (cons arg-val rest-val)))
                                 fail2
                                 rest))
               fail
               arg)]))

(define (eval-application env continue fail fun args)
  (eval-exp env
            (λ (fail2 fun-val)
              (eval-arguments env
                              (λ (fail3 args-val)
                                (apply fun-val continue fail3 args-val))
                              fail2
                              args))
            fail
            fun))

(define (eval-require env continue fail exp)
  (eval-exp env
            (λ (fail2 value)
              (if value
                  (continue fail2 value)
                  (fail)))
            fail
            exp))

(define (eval-amb env continue fail exps)
  (match exps
    [(list) (fail)]
    [(list exp rest ...)
     (eval-exp env
               continue
               (λ () (eval-amb env continue fail rest))
               exp)]))

(define (eval-sequence env continue fail terms)
  (match terms
    [(list exp) (eval-exp env continue fail exp)]
    
    [(list (list 'define name exp) rest ...)
     (eval-exp env
               (λ (fail2 value)
                 (define new-env (extend-environment env (list name)(list value)))
                 (eval-sequence new-env continue fail2 rest))
               fail
               exp)]
 
    [(list trm rest ...)
     (eval-exp env
               (λ (fail2 ignored)
                 (eval-sequence env continue fail2 rest))
               fail
               trm)]))

(define (eval-exp env continue fail exp)
  (match exp
    [(? symbol?) (continue fail (lookup env exp))]
    [(? number?) (continue fail exp)]
    [(? boolean?) (continue fail exp)]
    
    [(list 'if exp then else)
     (eval-exp env
               (λ (fail2 value) (eval-exp env continue fail2 (if value then else)))
               fail
               exp)]

    [(list 'require exp)
     (eval-require env
                   continue
                   fail
                   exp)]

    [(list 'amb exps ...)
     (eval-amb env
               continue
               fail
               exps)]

    [(list 'begin terms ...) (eval-sequence env continue fail terms)]
    
    [(list 'λ parameters body ...) (continue fail (make-function env parameters body))]

    [(list 'lambda parameters body ...) (continue fail (make-function env parameters body))]

    [(list fun args ...) (eval-application env continue fail fun args)]
    
    [_ (error 'wat (~a exp))]))

(define (evaluate input)
  (eval-exp primitives
            (λ (fail res) res)
            (λ () (error 'ohno))
            input))

(define (evaluate* input)
  (eval-exp primitives
            (λ (fail res) (cons res (fail)))
            (λ () '())
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
   (eval-require primitives
                 (λ (x f) #t)
                 (λ () #f)
                 '(< 3 6))
   #t)
  (check-equal?
   (eval-require primitives
                 (λ (x f) #t)
                 (λ () #f)
                 '(> 3 6))
   #f)

  (check-equal?
   (evaluate
    '(begin
       (define a (amb 1 (- 5 3) 6 8))
       (require (> a 5))
       a))
   6)

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

  (check-equal?
   (evaluate
    '(begin
       (define a (amb 1 3 5 7))
       (define b (amb 2 4 3 6))
       (require (= (+ a b) 9))
       (list a b)))
   '(3 6))

  (check-equal?
   (evaluate*
    '(begin
       (define a (amb 1 (- 5 3) 6 8))
       (require (> a 5))
       a))
   '(6 8))
  
  (check-equal?
   (evaluate*
    '(begin
       (define a (amb 1 3 5 7))
       (define b (amb 2 4 3 6))
       (require (= (+ a b) 9))
       (list a b)))
   '((3 6) (5 4) (7 2)))
  )
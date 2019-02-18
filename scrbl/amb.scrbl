#lang scribble/manual

@(require "util.rkt")

@title{Ambiguousness}

@intro-para["6-booleans.rkt"]

@para{
 Now that we have continuations, we will add continuations.
}
@para{
 We want to add support for the new forms @(racket amb) and @(racket require).
 An @(racket amb) with multiple expressions, @(racket (amb exps ...)) is a form that evaluates to the value of one of its expressions.
 A @(racket require) with an expression, @(racket (require exp)), succeeds if the expression evaluates to true (@(racket #t)) and fails if it evaluates to false (@(racket #f)).
 If a @(racket require) fails,
 the evaluator should backtrack to the last @(racket amb) and try to continue from there with the value of one of the ``remaining'' expressions of that @(racket amb).
}
@para{
 For taking care of the backtracky bits, we will use a @(racket fail)-continuation in addition to the @(racket continue)-continuation.
}

@section[#:tag "amb-tests"]{Some tests}

@intro-test-para

@(racketblock
  (check-equal?
   (eval-require primitives
                 (λ (x f) #t)
                 (λ () #f)
                 '(< 3 6))
   #t))
@(racketblock
  (check-equal?
   (eval-require primitives
                 (λ (x f) #t)
                 (λ () #f)
                 '(> 3 6))
   #f))

@(racketblock
  (check-equal?
   (evaluate
    '(begin
       (define a (amb 1 (- 5 3) 6 8))
       (require (> a 5))
       a))
   6))

@(racketblock
  (check-exn
   exn:fail?
   (λ()
     (evaluate
      '(begin
         (define a (amb 1 2 3))
         (require (> a 5))
         a)))))

@(racketblock
  (check-equal?
   (evaluate
    '(begin
       (define a (amb 1 3 5 7))
       (define b (amb 2 4 3 6))
       (require (= (+ a b) 9))
       (list a b)))
   '(3 6)))

@(racketblock
  (check-equal?
   (evaluate*
    '(begin
       (define a (amb 1 (- 5 3) 6 8))
       (require (> a 5))
       a))
   '(6 8)))

@(racketblock
  (check-equal?
   (evaluate*
    '(begin
       (define a (amb 1 3 5 7))
       (define b (amb 2 4 3 6))
       (require (= (+ a b) 9))
       (list a b)))
   '((3 6) (5 4) (7 2))))

@section{Some stuff will have a @(racket fail)-parameter}

@para{
 The functions we use as @(racket continue)-continuations, as well as all functions that have @(racket continue)-parameters, should also have @(racket fail)-parameters.
 Like, we will change continuation-lambdas like  @(racket (λ (value) #,(emph "stuff"))) to ones like @(racket (λ (fail value) #,(emph "stuff"))),
 and things like @(racket (eval-exp env continue exp)) to things like @(racket (eval-exp env continue fail exp)).
 For now, the different functions will just pass their @(racket fail)s along.
}

@para{
 The @(racket evaluate)-function should work like before. Just, it's @(racket continue)-argument should accept a failure-continuation in addition to the result,
 and it should pass some @(racket fail)-argument to @(racket eval-exp):
}
@(racketblock
  (define (evaluate input)
    (eval-exp primitives
              (λ (fail res) res)
              (λ () (error 'ohno))
              input)))

@section{@(racket require)}

@para{
 In @(racket eval-exp) we will add a clause:
}
@(racketblock
  [(list 'require exp)
   (eval-require env
                 continue
                 fail
                 exp)])
@para{
 And make the function @(racket (eval-require env continue fail exp)).
 In @(racket eval-require) we will evaluate @(racket exp).}

@para{The continuation we pass along to @(racket eval-exp) should carry on with @(racket continue) if @(racket exp) evaluated to true,
 or use @(racket fail) if it evaluated to false.
 The @(racket fail)-continuation should not take any arguments.
}

@para{
 The two tests that use @(racket eval-require) should pass after this.
}


@section{@(racket amb)}

@para{
 To @(racket eval-exp) we add:
}

@(racketblock
  [(list 'amb exps ...)
   (eval-amb env
             continue
             fail
             exps)])

@para{
 And we make the function @(racket (eval-amb env continue fail exps)).
}

@para{
 In @(racket eval-amb) we will @(racket match) the @(racket exps)-list.
 If @(racket exps) is empty, we @(racket (fail)).
 If @(racket exps) has at least one element, we will evaluate that expression with @(racket eval-exp):
}
@para{
 We can pass our @(racket continue)-continuation along.
}
@para{
 But we need to make a new failure-continuation, @(racket (λ () #,(emph "your code here"))).
 We will make it so that if anything fails later in the program, we will @(racket eval-amb) with the remaining elements of the @(racket exps)-list.
 (When we run out of elements in @(racket exps), we will invoke our ``original'' @(racket fail)-continuation, as per our first @(racket match)-clause.)
}

@section{Btw let's add a @(racket list)-function to our @(racket primitives)}

@para{
 Just, it would be nice to return multiple values now, so we will add Racket's @(racket list)-function to the @(racket primitives) list.
}

@section{@(racket evaluate*)}

@para{
 So @(racket evaluate) should work mostly like before, and it will return the first solution, or throw an error if there aren't any.
}

@para{
 It would be neat to have an evaluation-function that could return a list of solutions instead. So we will make one.
 In @(racket evaluate*), we, uh, ``replace failure with a list of successes,'' maybe:
}

@(racketblock
  (define (evaluate* input)
    (eval-exp primitives
              (λ (fail res) (cons res (fail)))
              (λ () '())
              input)))

@para{
 Now we can, say, make a program for finding numbers that add up to 10:
}

@(racketblock
  (define adds-up-to-10
    '(begin
       (define a (amb 1 2 3 4 5 6 7 8 9))
       (define b (amb 1 2 3 4 5 6 7 8 9))
       (require (= (+ a b) 10))
       (list a b))))

@para{
 And we can get one solution with @(racket (evaluate adds-up-to-10)), or several solutions with @(racket (evaluate* adds-up-to-10)).
}

@section[#:tag "amb-done"]{Done?}

@@outro-test-para

@para{
 Next: Maybe @secref{It_s_puzzle_time}, or we can go @secref{Towards_zebras}. We should be equipped for either.
 We can keep using the Racket-file we're working with, or skip to @tt{7-amb.rkt}..
}
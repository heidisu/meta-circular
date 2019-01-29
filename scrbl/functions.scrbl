#lang scribble/manual

@(require "util.rkt")

@title{Functions}

@intro-para["3-definitions.rkt"]

@para{
 Functions are good for parameterizing pieces of code.
}

@para{
 A function in our language wil be built from a list of parameter names and a list of terms for the function body.
 When called, the function should extend its environment with its parameters bound to the arguments supplied by the caller,
 and then evaluate the body.
}

@section[#:tag "fun-tests"]{Some tests}

@intro-test-para

@(racketblock
  (check-equal?
   (evaluate '((λ () (+ 2 3))))
   5))


@(racketblock
  (check-equal?
   (evaluate '((lambda (x y) (+ x y)) 3 4))
   7))


@(racketblock
  (check-equal?
   (evaluate
    '((lambda ()
        (define a 2)
        (define b 3)
        (+ a b))))
   5))

@(racketblock
  (check-equal?
   (evaluate
    '((lambda ()
        (define a 2)
        (define b (lambda (c) (define a 5) (+ a c)))
        (b a))))
   7))


@section{Make a function}

@para{
 When @(racket eval-exp) encounters a ``lambda'' we want to make a real Racket function.
}

@para{
 We make @(racket make-function) function:
}

@(racketblock
  (define (make-function env parameters body)
    (λ arguments
      #,(emph "your code here"))))

@(itemlist
  @item{@(racket env) is the environment the function @emph{was defined in.}}
  @item{@(racket parameters) is a list of parameter names (symbols).}
  @item{@(racket body) is a list of terms. Maybe an expression. Maybe some @(racket define)s and then an expression.})

@para{
 @(racket make-function) returns a Racket-function (made with the @(racket λ)).
 That function should extend the environment it was defined in with each parameter name bound to the corresponding argument-value,
 and then @(racket eval-sequence) its @(racket body).
}


@section{New match clauses in @(racket eval-exp)}

@(racketblock
  [(list 'λ parameters body ...) #,(emph "your code here")])

@para{
 When the @(racket 'λ) matches we want to make a function with @(racket make-function).
}

@para{
 Also, we will add a very similar match-clause, for when people use @(racket lambda) instead of @(racket λ).
}

@section[#:tag "func-done"]{Done?}

@outro-test-para
@outro-para["Continuation-passing_style" "4-functions.rkt"]

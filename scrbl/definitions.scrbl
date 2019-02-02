#lang scribble/manual

@(require "util.rkt")

@title{Definitions}

@intro-para["2-lookup-in-environment.rkt"]

@para{
 Passing an unchanging environment around is @emph{pretty cool}.
 Maybe it would also be cool if the environment could also be extended with more stuff.
 Will try to.
}

@para{
 We will use a ``definition'' to bind a name to a value, so that values can be referred to by their names.
 When we encounter a definition we will extend the environment with a new binding.
}

@section[#:tag "def-tests"]{Some tests}

@intro-test-para

@(racketblock
  (check-equal?
   (extend-environment (list (cons 'd 2) (cons 'e 1))
                       (list 'a 'b 'c)
                       (list 5 4 3))
   (list (cons 'a 5) (cons 'b 4) (cons 'c 3) (cons 'd 2) (cons 'e 1))))

@(racketblock
  (check-equal?
   (evaluate
    '(begin
       (define a 2)
       (define b 3)
       (+ a b)))
   5))
          
@(racketblock
  (check-equal?
   (evaluate
    '(begin
       (define a 2)
       (define a 3)
       (+ a a)))
   6))


@section{@(racket define) in Racket}

@para{
 Our defintions are going to work rather like the regular Racket ones.
 Try out the following lines of code in the REPL:
}

@(racketblock (define a 2))

@(racketblock a)

@(racketblock (define b +))

@(racketblock (b a 3))

@(racketblock
  (begin
    (define a 3)
    (+ a 3)))

@section{@(racket extend-environment)}

@para{
 We would like a helper-function for extending an environment with new bindings.
 We want to use this for definitions, and also for adding arguments to the environment when functions are called.
 Functions can have multiple parameters, so we will make @(racket extend-environment) take a list of @(racket names)
 and a list of @(racket values), in addition to the @(racket env)ironment it should extend:
}

@(racketblock
  (define (extend-environment env names values)
    #,(emph "your code here")))

@para{
 The function should return a new list containing new pairs of names and values and all the pairs from @(racket env).
 The Racket function @(racket append) will be useful.
 Also useful: Racket's @(racket map)-function can take multiple lists of same length as arguments. Like:
}
@(racketblock
  (map cons (list 'a 'b 'c) (list 1 2 3)))

@para{
 When done, the test that uses @(racket extend-environment) should pass.
}

@section{@(racket eval-sequence) and @(racket define)}

@para{
 Definitions are not ``expressions'' in our language: We do not evaluate a definition in order to get some value. It only extends the environment.
 That kind of means that evaluating a program that is only a definition is not an incredibly meaningful thing to do.
 Like, we, uh, we want results.
}
@para{
 So, we're going to add support for evaluating multiple terms, on after another.
 Typically one or more definitions and then an expression at the end.
}

@para{We make function:}

@(racketblock
  (define (eval-sequence env terms)
    (match terms
      [(list exp)  #,(emph "your code here")]

      [(list (list 'define name exp) rest ...)  #,(emph "your code here")]

      [(list trm rest ...)  #,(emph "your code here")])))

@para{
 In the @emph{first} match-clause:
 The list only consist of only one element.
 The one element in a one-element list is its final element.
 The final term in a sequence is the expression we want to evaluate in order to get its result value.
 We can use @(racket eval-exp).
}

@para{
 In the @emph{last} match-clause:
 Since the middle clause did not match, @(racket trm) is not a @(racket define)-form.
 We will evaluate it with @(racket eval-exp), throw away its result, and use @(racket eval-sequence) on the  @(racket rest) of the terms.
 (Yea so throwing away the results seems possibly wasteful. Maybe side effects though?)
}

@para{
 In the @emph{middle} match-clause:
 A @(racket define)-form. This is more trickier.
 First we should evaluate the @(racket exp)ression part of the defintion,
 and create a new environment with @(racket extend-environment). 
 Then we can call @(racket eval-sequence) on the @(racket rest) of the list and the new environment.
}

@section{@(racket begin)}

@para{
 We use @(racket begin)-forms to create expressions out of lists of terms.
 We add a new match-clause in @(racket eval-exp):}

@(racketblock [(list 'begin terms ...) #,(emph "your code here")])

@para{
 And we will use @(racket eval-sequence) to deal with the @(racket terms).
}

@section[#:tag "def-done"]{Done?}

@outro-test-para
@outro-para["Functions" "3-definitions.rkt"]

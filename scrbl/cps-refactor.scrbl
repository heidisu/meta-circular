#lang scribble/manual

@(require "util.rkt")

@title{Refactoring to CPS}

@intro-para["4-functions.rkt"]

@para{
 CPS, besides being weird, is kind of neat.
 If you're implementing a function,
 and the ``continuation'' ---everything that is to happen after--- is made available to you as a function,
 then, uh, that's a thing you're in control of.
}
@para{
 You can decide not to invoke the continuation.
 Or you can try to invoke the continuation several times, with different values.
 Later on we want to use an @(racket amb)-form for expressions that can have multiple possible values:
 We want to ``continue'' with some value, and if that turns out to be no good, we want to try some other value instead.
 CPS seems like a good fit.
}

@section{Some stuff will have a @(racket continue)-parameter}

@para{
 We will rewrite a few functions so they have a @(racket continue)-parameter,
 and so that, instead of returning a result, they apply @(racket continue) to a result.
 We will put @(racket continue) just after @(racket env) in the parameter lists.
 E.g. @(racket eval-application) will go like @(racket (eval-application env continue fun args)).
}

@subsection{@(racket (eval-exp env continue exp))}

@para{
 @(racket eval-exp) isn't too bad. In most of the @(racket match)-clauses we return a value pretty directly.
 In those cases we will pass the values along to @(racket continue) instead.
 In the case where we call @(racket eval-application), we will pass our @(racket continue) along to @(racket eval-application) and put it in after @(racket env) parameter. The same goes for @(racket eval-sequence).
}

@subsection{@(racket (eval-sequence env continue exps))}

@para{
 The cases where we have some @(racket rest)-expressions are a little trickier.
 In, say, the @(racket 'define)-case, we must make a continuation-function to use with @(racket eval-exp). Like:
}

@(racketblock
  (eval-exp env
            (λ (value)
              #,(emph "your code here"))
            exp))

@para{
 Within this continuation-function, we will do the stuff we previously did @emph{after} the call to @(racket eval-exp):
 Extend the environment and call @(racket eval-sequence) again. We will pass our ``original'' @(racket continue) to @(racket eval-sequence).
}

@subsection{@(racket (eval-application env continue fun args))}

@para{
 Maybe the trickiest. We must evaluate the @(racket fun)-expression with @(racket eval-exp), with a continuation that deals with the arguments.
 For every argument in the list, there will be a call to @(racket eval-exp) with a continuation that deals with
 the rest of the arguments and performing the function application. Along the way we must keep track of the arguments we have evaluated.
 Finally, the function we are going to apply will take a @(racket continue)-argument before the evaluated @(racket args):
 We will pass our @(racket continue)-parameter along to it.
}
@para{
 It is likely that evaluating the arguments is the hardest bit. We probably want this:
}
@(racketblock
  (define (eval-arguments env continue args)
    (match args
      ['() #,(emph "your code here")]
      [(list arg rest ...) #,(emph "your code here")])))
@para{
 In @(racket '())-case: Evaluating all the arguments in the empty list is maybe not @emph{too} hard?
}
@para{
 In the @(racket (list arg rest ...))-case:
 We want to @(racket eval-exp) the @(racket arg),
 then @(racket eval-arguments) the @(racket rest) of the arguments,
 and then @(racket cons) the evaluated argument onto the evaluated rest-of-the-arguments.
 Like, we're really ``just'' trying to map @(racket eval-exp) over @(racket args). Having to work out what needs to go in which continuation makes things more confusing though.
}

@subsection{Our ``primitives''}

@para{
 Instead of e.g. the @(racket +)-function we want a function that has a @(racket continue)-argument first:
}

@(racketblock
  (define (my-plus continue . args)
    #,(emph "your code here")))

@para{
 When this function is applied, all the arguments after the @(racket continue) are collected in  @(racket args), as a list.
 We can use the @(racket apply)-function to apply the original @(racket +)-function to the @(racket args).
 (And we want to apply @(racket continue) to the result rather than just returning it.)
}

@para{
 It is pretty possible, while not exactly necessary, to make a helper-function for this.
 One that takes a regular function as its argument and returns a more CPS-compliant function.
 Something along the lines of
}
@(racketblock
  (define (primitive function)
    (λ (continue . args)
      #,(emph "your code here"))))

@para{
 could be convenient.
}


@subsection{@(racket (make-function env parameters body))}

@para{
 We're not adding a @(racket continue)-parameter to @(racket make-function) function,
 but we need to add it to the function returned by @(racket make-function).
 That @(racket continue) should be passed in as the second argument to @(racket eval-sequence).
}

@subsection{@(racket (evaluate input))}

@para{
 For now, we want @(racket evaluate) to work the same way as before, so we are not adding a @(racket continue)-parameter to it.
 But it does use @(racket eval-exp) so we need to add a @(racket continue)-argument there.
 We will use Racket's @(racket identity)-function.
}

@section{So that did nothing}

@para{
 So, if we got things right then we have kind of made no changes.
 Under the hood things work differently,
 but there are no new features and all the expressions in the language we're making should @(racket evaluate) to the same values.
}

@para{
 How dull? On the plus side we didn't have to write any new tests...
}

@section{Couple of tips, maybe}

@para{
 Okay so this stuff is like not straightforward.
 Because CPS.
 Also because we have to change a bunch of of interdependent functions: We change one and everything breaks.
 So. Two tips:
}
@para{
 One tip:
 Use Racket's @(racket identity)-function for stuff.
 If you pass @(racket identity) in as the @(racket continue)-argument to a function, then @(racket identity) should just return the result we're intersted in.
}
@para{
 Another tip:
 Maybe change @(racket eval-exp) so that it handles the simplest expression, the literals, correctly first, and let everything else break.
 Then, when rewriting each ``feature'' to CPS, we can test them with expressions where all the subexpressions are just literals.
 E.g. when working on @(racket eval-arguments), just use a list of numbers for the @(racket args) to begin with.
}

@section[#:tag "cps-done"]{Done?}

@outro-test-para
@outro-para["Booleans" "5-continuation-passing-style.rkt"]

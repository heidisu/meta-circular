#lang scribble/manual

@(require "util.rkt")

@title{Lookup in the environment}

@intro-para["1-fixed-calculator.rkt"]

@para{
 We see that most of the match-clauses in @(racket eval-exp) look quite similar.
 We will do some steps of refactoring in order to not repeat ourselves, and also to be prepared for things to come.
 Later the users of the program will be able to define their own variables with names they choose themselves,
 so we do not want to continue to match on the names (@(racket '+), @(racket '-) and so on) as we currently do in @(racket eval-exp).
 Instead we will look up the values of variables in some lookup-table that can be extended dynamically.
}

@section[#:tag "lookup-tests"]{Some tests}

@intro-test-para

@(racketblock
  (check-equal?
   (lookup (list (cons 'a 1)
                 (cons 'b 2))
           'a)
   1))

@(racketblock
  (check-equal?
   (lookup (list (cons 'a 1)
                 (cons 'b 2))
           'b)
   2))

@(racketblock
  (check-equal?
   (lookup (list (cons 'a 0)
                 (cons 'a 1)
                 (cons 'b 2))
           'a)
   0))

@(racketblock
  (check-exn
   exn:fail?
   (λ ()
     (lookup (list (cons 'a 1)
                   (cons 'b 2))
             'c))))

@section{An environment}

@para{
 Idea is: Whenever we evaluate an expression, we will have an environment with bound variables and their values,
 and when we evaluate a variable reference, we will look up its value in the environment.
}

@para{An environment can look like:}

@(racketblock '((a . 5) (b . 4) (c . 3) (a . 7)))

@para{
 In this environment, looking up @(racket 'b) should give us @(racket 4) and @(racket 'c) should give us @(racket 3).
 @(racket 'a) should give us @(racket 5). New bindings are added to the beginning of the list, and newer bindings shadow older ones.
 We can't reach the @(racket 'a) that is bound to @(racket 7).
}

@section{@(racket primitives)}

@para{
 We will start off by making a list called @(racket primitives) containing our four primitive operators,
 and look up in this list every time the function @(racket eval-exp) sees a symbol.
 We will use @(racket list) to construct the list of bindings.
 Each binding will be a pair, constructed with @(racket cons).
}
@(racketblock
  (define primitives
    (list (cons '+ +)
          #,(emph "more bindings"))))
  

@section{@(racket lookup)}

@para{
 We will implement this as a recursive function.
 If the first binding in the list is equal to the symbol we are looking for then we return the corresponding value,
 otherwise we call lookup on what remains of the list.
 If the list is empty it doesn't have the binding we're looking for, and we will raise an exception.
}

@para{
 We will make the @(racket lookup)-function:
}
@(racketblock
  (define (lookup env s)
    (match env    
      #,(emph "your code here"))))

@para{
 It should have a couple of match-clauses:
}

@para{
 One should match the empty list (e.g. @(racket (list)) or @(racket '())), and throw an exception.
 We can use Racket's @(racket error)-function to raise an exception
 (see the function @(racket eval-exp) for an example of use of @(racket error)).
}
@para{
 The more difficult part is to match a list with a binding (a @(racket cons)-pair) as its first element.
 We can use a clause like:
}
@(racketblock [(list (cons name val) rest ...) #,(emph "your code here")])
@para{
 If this matches it will pick out the parts we need:
 @(racket name) will be bound to a variable name and @(racket val) to its value,
 and @(racket rest) will be bound to the rest of the list.
 We then want to check @(racket if) @(racket name) is @(racket equal?) to @(racket s),
 and return @(racket val) if it is,
 or else call lookup on @(racket s) and the @(racket rest) of the list.
}

@para{
 The tests we added should pass when we're done.
}

@section{Environment as input to @(racket eval-exp)}

@para{
 We will pass @(racket primitives) as an argument to @(racket eval-exp), and make @(racket eval-exp) use it to look up values.
 So, in the definition of @(racket eval-exp), instead of
}

@(racketblock (eval-exp exp))

@para{
 we will have have
}

@(racketblock (eval-exp env exp))

@para{
 @(racket env) will be the list of bindings we will use for looking up stuff.
}

@para{
 We should modify the @(racket evaluate)-function so that it passes @(racket primitives) along to @(racket eval-exp).
}

@subsection{Looking up}

@para{
 Now that @(racket eval-exp) has an @(racket env)ironment we can use it for when there are symbols:
}
@(racketblock [(? symbol?) #,(emph "your code here")])

@para{
 When this matches we want to apply our @(racket lookup)-function to @(racket env) and @(racket exp).
}

@subsection{@(racket eval-application)}

@para{
 Now, instead of having different match-clauses for @(racket '+) and @(racket '-) and so on,
 we can have one clause for function application:
}

@(racketblock [(list fun args ...) (eval-application env fun args)])

@para{
 We should be able to evaluate the @(racket fun)-expression to get the correct function.
 We're using a helper function:
}

@(racketblock
  (define (eval-application env fun args)
    #,(emph "your code here")))

@para{
 It should evaluate the @(racket fun)-expression and all the expressions in the @(racket args) list,
 and @(racket apply) the evaluated  @(racket fun) to the evaluated @(racket args).
}

@para{
 Should be pretty similar to what we used to do when we matched e.g. @(racket '+),
 only we don't use a hardcoded function (like @(racket +)),
 and we need to pass the @(racket env)ironment along whenever we call @(racket eval-exp).
 It can be useful with a lambda function.
}

@section[#:tag "lookup-done"]{Done?}

@outro-test-para
@outro-para["Definitions" "2-lookup-in-environment.rkt"]

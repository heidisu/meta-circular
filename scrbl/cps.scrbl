#lang scribble/manual

@title{Continuation-passing style}

@para{
 (Not really working with the Racket file in this part. Can play with stuff in the Racket REPL.)
}

@para{
 Say we want a function that adds two to its argument.
}

@section{Not CPS}

@para{
 A reasonably normal way to go about things could be:
}
@(racketblock
  (define (add2 x)
    (+ x 2)))
@para{
 If we wanna apply it to the number three and display the result, then we can apply it to @(racket 3) and @(racket display):
}
@(racketblock
  (display (add2 3)))
@para{
 Chances are the number @(racket 5) will be displayed.
}

@section{CPS}

@para{
 A less normal way to go about things could be:
 Instead of @(racket add2)-function taking just one argument,
 it could take two arguments and the second argument could be a ``continuation''-argument.
 And instead @(racket add2) returning the result of the addition,
 it could apply its ``continuation'' to the result.
}
@(racketblock
  (define (add2 x continue)
    (continue (+ x 2))))
@para{
 Now, if we wanna display the result, we do not apply @(racket display) to the result.
 Instead we pass in @(racket display) as @(racket add2)'s @(racket continue)-argument.
}
@(racketblock
  (add2 3 display))
@para{
 If we don't exactly have the exact functions we want at hand, we can make them with lambdas.
}

@(racketblock
  (add2 3
        (λ (result)
          (add2 result
                (λ (final-result)
                  (printf "it's ~a" final-result))))))

@para{
 So that's weird.
 Anyway we're passing continuations. That style of programming is called continuation-passing style (CPS).
}

@para{
 Next is @secref{Refactoring_to_CPS}.
}
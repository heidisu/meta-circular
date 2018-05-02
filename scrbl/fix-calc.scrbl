#lang scribble/manual

@(require "util.rkt")

@(require (only-in images/icons/control play-icon)
          (only-in images/icons/misc stop-sign-icon)
          (only-in images/icons/style run-icon-color))

@title{Fixing the calculator}

@para{
 Should open the @tt{0-start-calculator.rkt}-file in DrRacket.
}

@section{Working with a file in DrRacket}

@para{
 Click the @(play-icon #:color run-icon-color)-button, or press @tt{F5}.
 DrRacket runs the file and the window kind of splits in two.
}

@(itemlist
  @item{
 The bit above is the Definitions bit.
 The contents of the file goes in Definitions; if we save the file it's the stuff in Definitions that will be saved.
}
  @item{
 The bit below is the Interactions bit.
 This is like a REPL. We can write Racket expressions here and have them evaluated.
 The Definitions are made available for Interactions whenever we Run the file.
 })

@para{
 There's a failing test. We'll get back to that.
}

@para{
 For now, try to run some expressions in Interactions. Maybe some of these:
}

@(racketblock
  (+ 2 3)
  )

@(racketblock
  (evaluate '(+ 2 3))
  )

@(racketblock
  (repl)
  )

@section{The calculator-code}

@para{
 There's some stuff going on...
}

@(racketblock
  (define (eval-exp exp)
    (match exp
      [(? number?) exp]

      [(list '+ args ...) (apply + (map eval-exp args))]
    
      [(list '- args ...) (apply - (map eval-exp args))]
    
      [(list '* args ...) (apply * (map eval-exp args))]
    
      [(list '/ args ...) (apply * (map eval-exp args))]
    
      [_ (error 'wat (~a exp))])))

@(racketblock
  (define (evaluate input)
    (eval-exp input)))

@(racketblock
  (define (repl)
    (printf "> ")
    (define input (read))
    (unless (eof-object? input)
      (define output (evaluate input))
      (printf "~a~n" output)
      (repl))))

@subsection{@(racket define)}

@para{
 The first @hyperlink["https://docs.racket-lang.org/reference/define.html"]{@(racket define)}-form defines a function called @(racket eval-exp) that takes one argument, @(racket exp).
 For now, the @(racket eval-exp)-function is the most important piece of code. It is for evaluating and expression and returning the result.
}

@subsection{@(racket read) and quotes}

@para{
 The following is a regular Racket-expresssion:
}

@(racketblock (+ 1 2))

@para{
 It is the application of the function @(racket +) to the arguments @(racket 1) and @(racket 2).
}
@para{
 We can @hyperlink["https://docs.racket-lang.org/reference/quote.html"]{``quote''} a term:
}
@(racketblock '(+ 1 2))
@para{
 This is not a function application. It evaluates to a list with three elements:
 The symbol @(racket '+), the number @(racket 1), and the number @(racket 2).
 We can ``quote'' a term in order to get the syntax of the term as a data object.
}

@para{Try out the following expressions in the REPL, and notice the differences.}

@(racket
  (+ 1 2))

@(racket
  '(+ 1 2))

@(racket
  (list + 1 2))

@(racket
  (list '+ 1 2))

@para{If you would like to check if two values are equal to each other, the function @(racket equal?) is handy.}

@para{
 The programs we will evaluate with our evaluator are data objects like the ones we get by quoting Racket terms.
 So we can write terms that are like regular Racket terms, quote them and pass them to our evaluator:
}
@(racketblock (evaluate '(+ 1 2)))

@(racket
  (equal? '(+ 1 2) (list '+ 1 2)))

@para{
 The @(racket repl)-function is a Read-Eval-Print-Loop.
 It uses the @(racket read)-function to read a Racket term.
 @(racket read) reads a Racket term and returns a data object, same as we would get if that term was quoted in a regular Racket program.
 @(racket repl) then @(racket evaluate)s, @(racket printf)s the result, and, by calling itself recursively, loops.
}

@para{
 So we can use the @(racket repl)-function to get a repl for the language we are making.
 Nice to have, can be fun to play around with.
 (But we will usually call @(racket evaluate) directly, with quoted Racket terms, when testing the evaluator during the workshop.)
}

@subsection{@(racket match)}

@para{
 Inside the @(racket eval-exp)-function there is a @hyperlink["https://docs.racket-lang.org/reference/match.html"]{@(racket match)}-form.
 @(racket match) is used for pattern matching.
 It matches @(racket exp) against a series of patterns, and evaluates some ``body''-code for the first pattern that matches.
 Each ``clause'' consists of a pattern and some ``body''-code. So:
}
@(itemlist
  @item{
 The pattern @(racket (? number?)) matches if @(racket exp) is a number (if the @(racket number?)-function returns true when applied to @(racket exp).
 If it matches, @(racket eval-exp) will return (the number) @(racket exp).
}
  @item{
 The pattern @(racket (list '+ args ...)) matches if @(racket exp) is a list where the first element is the symbol @(racket '+).
 If it matches, @(racket (apply + (map eval-exp args))), with @(racket args) bound to the rest of the @(racket exp)-list, will be evaluated.
 @(racket eval-exp) will return result.
}
  @item{
 The pattern @(racket (list '- args ...)) matches if the @(racket exp) is a list where the first element is the symbol @(racket '-).
 If it matches, @(racket (apply - (map eval-exp args))), with @(racket args) bound to the rest of the @(racket exp)-list, will be evaluated.
 @(racket eval-exp) will return result.
}
  @item{
 And so on.
}
  @item{
 @(racket _) matches whatever. If none of the patterns above match, this one will, and we will throw an error.
 })

@subsection{@(racket apply)}

@para{
 In most of the pattern matching clauses, we use the @hyperlink["https://docs.racket-lang.org/reference/procedures.html#%28def._%28%28lib._racket%2Fprivate%2Fbase..rkt%29._apply%29%29"]{@(racket apply)}-function.
 @(racket apply) is a function application function.
 If a function takes several arguments, and we have the arguments we want to apply it to in a list, we can use @(racket apply).
}

@para{
 Like, normally we apply the @(racket +)-function like so:
}
@(racketblock (+ 1 2 3))
@para{
 If we have a list @(racket lst) with numbers:
}
@(racketblock (define lst (list 1 2 3)))
@para{
 Then we cannot apply @(racket +) directly to the @(racket lst)-list.
 @(racket +) can be applied to severl number-arguments, not one list-with-several-numbers-argument.
 But we can use @(racket apply):
}
@(racketblock (apply + lst))

@section{Making the test pass}

@para{
 Lets's make the failing test pass:
}

@(itemlist
  @item{Quickest way to get back to the failure is to run (@tt{F5}) the file again.}
  @item{DrRacket should highlight the failing test in the definitions window, or we can click on the @(stop-sign-icon) in the REPL to highlight it again.}
  @item{We can stare at the failing test and at the @(racket eval-exp)-code for a little while.}
  @item{And then fix.})

@section[#:tag "fix-calc"]{Done?}

@outro-para["Lookup_in_the_environment" "1-fixed-calculator.rkt"]


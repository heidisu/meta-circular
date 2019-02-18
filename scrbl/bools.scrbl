#lang scribble/manual

@(require "util.rkt")

@title{Booleans}

@intro-para["5-continuation-passing-style.rkt"]

@para{
 Add booleans. Go blind.
}

@section[#:tag "bool-tests"]{Some tests}

@intro-test-para

@(racketblock
  (check-equal?
   (evaluate '(if #f (+ 1 2) (+ 2 3)))
   5))

@(racketblock
  (check-equal?
   (evaluate '(if (> 8 4) (+ 1 2) 0))
   3))

@(racketblock

  (check-equal?
   (evaluate '((λ (a b)
                 (if (> a (+ b b)) (- a b) (+ a b)))
               9 1))
   8))

@(racketblock  
  (check-equal?
   (evaluate '((λ (a b)
                 (if (> a (+ b b)) (- a b) (+ a b)))
               9 5))
   14))

@section{Literals}

@para{
 We want to have two boolean literals: @(racket #t) (true) and @(racket #f) (false).
 In @(racket eval-exp) these can be matched and handled quite the same way as number-literals.
 We can use Racket's @(racket boolean?)-function to match booleans, the way we use the @(racket number?)-function to match numbers. 
}

@section{@(racket if)}

@para{
 And we want some kind of if-then-else.
 In @(racket eval-exp) we add a clause:
}
@(racketblock [(list 'if exp then else) #,(emph "your code here")])
@para{
 If it matches, we will evaluate the @(racket exp)-expression,
 then choose @(racket then)-expression or @(racket else)-expression depending on the value we got,
 and then evaluate the expression we chose.
}

@section{Some functions}

@para{
 And also we probably want some functions, like @(racket =) and @(racket <) and so on.
 Since our numbers are Racket-numbers and our booleans are Racket-booleans we can add them the same way we have added the other ``primitives,''
 like @(racket +) and @(racket -) and such.
}
@para{
 We will add at least @(racket =), @(racket <), @(racket <=), @(racket >) and @(racket >=).
 We can add more later if we need more...
}

@section{Maybe: @(racket and), @(racket or), ...}

@para{
 We can totally skip this part. It isn't necessary for any of the stuff we will do later. But it's maybe like nice or something.
}

@para{
 We can implement stuff like @(racket and) by matching on it in @(racket eval-exp) and then kind of rewriting to an @(racket if)-expression and evaluating that rewritten expression instead:
}

@(racketblock [(list 'and a b)
               (define rewritten-exp (list 'if #,(emph "your code here")))
               #,(emph "your code also here")])

@section[#:tag "bool-done"]{Done?}

@outro-test-para
@outro-para["Ambiguousness" "6-booleans.rkt"]


#lang scribble/manual
 
@title{Some Racket}
 
@para{
 We'll mostly introduce things when we're going to use them, but we'll mention a few things here...
}
@para{
 We are going to implement an evaluator for a language.
 We will write the evaluator in Racket. Racket is pretty lispy and schemey.
 The language we will make the evaluator for will also be pretty lispy and schemey.
 On the whole: Lispy and schemey.
}

@section{Maybe use DrRacket}

@para{
 The Racket installation comes with DrRacket, which you can use for writing and running programs and so on.
 It's pretty nice.
}
@para{
 Some things:
}
@(itemlist
  @item{@tt{Ctrl+\} inserts a λ-character}
  @item{@tt{F1} searches for the name of the identifier your cursor is on in the Racket documentation.}
  @item{@tt{F2} makes a blue box appear! (or disappear)}
  @item{@tt{Ctrl+i} indents everything appropriately}
  @item{@tt{Ctrl+↑}/{Ctrl+↓} for scrolling through previously used forms in the REPL})

@section{@(racket (function argument ...))}

@para{
 There will be stuff like:
}
@(racketblock (+ 1 2))
@(racketblock (string-append "zeb" "ra"))
@(racketblock ((λ (n) (+ n 1)) x))

@para{
 These are function application-forms.
 Each form is a pair of parentheses with some elements between them.
 The first element is the function. The other elements are the arguments.
}
@para{
 Okay.
}

@section{@(racket (something-else other-stuff ...))}

@(racketblock (if (< 7 x) "lessthan" "notlessthan"))
@(racketblock (define x (+ x 2)))
@(racketblock (λ (n) (+ n 1)))

@para{
 These are not function application-forms, but some other forms.
 Good to know.
}
@para{
 Anyway, the first element is usually kind of important.
 Like if you wanna know what the @(racket (define x (+ x 2))) bit does,
 it's probably better to press F1 with the cursor at @(racket define) and not like at @(racket x) or something.
 Also, in the evaluator we are going to implement, we will totally look at the first element of a form when deciding what to do.
}

@section{A very subsetty subset of Racket btw}

@para{
 We will try to write code in a style that isn't very far away from like, modern Racket, but without introducing an actual ton of Racket.
 We get most of the work done by working with lists/pairs and simpler data types like symbols and numbers, and then pattern matching lots.
}
@para{
 So like, people who are familiar with Racket-or-Scheme-or-Lisp might read some code and think something like:
}

@(itemlist
  @item{``This would be prettier with @hyperlink["https://docs.racket-lang.org/reference/quasiquote.html"]{quasiquotes and unquoting}.''}
  @item{Or ``can we please use @hyperlink["https://docs.racket-lang.org/reference/define-struct.html"]{structs} for this instead of just conses everywhere?''}
  @item{Or ``maybe @hyperlink["https://docs.racket-lang.org/reference/require.html"]{use multiple files}?''}
  @item{Or ``we should put these @hyperlink["https://docs.racket-lang.org/rackunit/index.html"]{checks} inside test cases and test suites.''}
  @item{Or something else...})

@para{
 Anyway it's totally okay to use parts of Racket that we don't mention in the workshop materials.
 We don't have to, but like, we can, it's fine.
}

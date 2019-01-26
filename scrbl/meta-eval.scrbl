#lang scribble/manual

@title{Meta-circular what?}

@para{
 The idea for this workshop comes from the classic book
 @hyperlink["https://mitpress.mit.edu/sites/default/files/sicp/index.html"]{Structure and Interpretation of Computer Programs} (SICP).
 It is a good book, you should read it!
}

@section{Programming languages and evaluators}

@para{A programming language is a language with a certain syntax and given rules,
 that makes you able to write programs that hopefully do what you expect them do do.}

@para{
 There are different strategies for how an implementation of a programming language executes programs. One approach is to make an evaluator.
 An @emph{evaluator} (or interpreter) for a language is a program that rather directly executes expressions written in that language.
 In order to execute the program, the evaluator needs to parse the expressions to something meaningful for the evaluator, and then evalute the expressions.
}

@para{
 When making a new language we can implement an evaluator in more or less any kind of language,
 but we will typically have to spend quite some time working on lexing and parsing before we have something meaningful or fun.
 We will use a subset of Racket's syntax for our language, and we will implement the evaluator in Racket.
 Reusing bits of our ``host language'' like that is what we do when we're making @emph{meta-circular evaluator}.
}

@para{
 But wait, why would we write (something very similar to) Racket in Racket when we already have a Racket?
 Well:
}
@(itemlist
  @item{Is fun.}
  @item{
 It can be easier to modify and experiment with a tiny language we have made ourselves.
 Easier to do things like, changing the evaluation order of things so that it's more lazier,
 or, as we will do in this workshop, add support for ``nondeterministic'' computaion.
}
  )

@section{@(racket amb) and logic programming}

@para{
 The way we will make Racket nondeterministic is by extending it with the form @(racket amb), which takes multiple expressions and returns one of them,
 and with @(racket require), which will allow us to specify constraints that must be satisfied.
 With those extensions we can write programs where the evaluator must search for solutions by choosing different values for the different @(racket amb)-expressions.
}

@para{
 This is a step towards logic programming where a problem is defined in terms of facts or rules, that might result in more than one answer.
 Unknown values are represented by variables,
 and @hyperlink["https://en.wikipedia.org/wiki/Unification_(computer_science)"]{unification} is used for solving the "equations" and determine the valid values.
}

@section{Outline}

@para{
 In this workshop we will start with a simple calculator evaluator, which allows us to calculate the value of expressions with the four basic operators +, -, * and /.
 And then gradually, through several steps, extend it until we have our nondeterministic evaluator @(racket amb).
}

@para{
 To begin with we will expand the calculator into a ``normal,'' but minimal and lispy, functional programming language.
 Mostly dealing with variables and functions:
 @secref{Lookup_in_the_environment}, @secref{Definitions}, @secref{Functions}.
}

@para{
 Starting with @secref{Continuation-passing_style}, we add the things we need for @secref{Ambiguousness}.
 @secref{Booleans} can be added kind of whenever,
 only we need them before moving @secref{Towards_zebras}, our ultimate goal.
}

@para{
 Not everything is new to everyone. It is possible to skip to where things get interesting.
 Every step has a corresponding Racket file that can be used as a starting point.
}

@section{Goals for the workshop}

@para{Our goals for this workshop is that you hopefully learn something new about}

@itemlist[#:style 'compact
          @item{The Racket programming language}
          @item{How evaluators work}
          @item{Continuation-passing style}
          @item{Logic programming}]
@para{but most of all, we hope you will }
@itemlist[#:style 'compact
          @item{Get inspiration and new ideas}
          @item{Have fun!}
          ]


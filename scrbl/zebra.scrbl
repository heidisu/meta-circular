#lang scribble/manual

@(require "util.rkt")

@title{Towards zebras}

@intro-para["7-amb.rkt"]

@para{
 If we add a few more things to our language, we can use amb to figure out who owns the zebra.
}

@section{What, if anything, is a zebra?}

@para{
 There exists multiple variations of the
 @hyperlink["https://en.wikipedia.org/wiki/Zebra_Puzzle"]{Zebra Puzzle}.
 We will use the one we find on Wikipedia:
}
@(itemlist
  #:style 'ordered
  @item{The Englishman lives in the red house.}
  @item{There are five houses.}
  @item{The Spaniard owns the dog.}
  @item{Coffee is drunk in the green house.}
  @item{The Ukrainian drinks tea.}
  @item{The green house is immediately to the right of the ivory house.}
  @item{The Old Gold smoker owns snails.}
  @item{Kools are smoked in the yellow house.}
  @item{Milk is drunk in the middle house.}
  @item{The Norwegian lives in the first house.}
  @item{The man who smokes Chesterfields lives in the house next to the man with the fox.}
  @item{Kools are smoked in the house next to the house where the horse is kept.}
  @item{The Lucky Strike smoker drinks orange juice.}
  @item{The Japanese smokes Parliaments.}
  @item{The Norwegian lives next to the blue house.})

@para{
 Now, who drinks water? Who owns the zebra?
}

@section{Adding stuff to our language}

@para{
 There's a few things that are necessary, or at least convenient, for solving the zebra puzzle.
}

@subsection{More list/pair functions}

@para{
 Can add some primitives:     
}

@(itemlist
  @item{@(racket cons) for constructing a list or pair}
  @item{@(racket car) for getting the first element of a list or pair}
  @item{@(racket cdr) for getting the tail of a list or the second element of a pair}
  @item{@(racket null?) for checking if something is the empty list})

@subsection{Quotes}

@para{
 In Racket, e.g. @(racket 'a) is translated to @tt{(quote a)} by the reader.
 If we want to support quotes in the language we're making, we can match on @(racket (list 'quote exp))
 and @(racket continue) with the quoted syntax, @(racket exp).
}

@para{
 Quoting can be convenient for list-laterals, like @(racket '()) and @(racket '(1 2 3)).
 Also for for symbols, like @(racket 'foo).
}

@subsection{Strings}

@para{
 Maybe we want strings, for values such as @(racket "red") and @(racket "zebra").
 (If we have added quotes to the language, we can choose to use values like @(racket 'red) and @(racket 'zebra) instead, and skip the strings.)
}
@para{
 If we're adding strings, we want to recognize string-literals in @(racket eval-exp),
 We can use @(racket string?) for this, same way we use @(racket number?) and @(racket boolean?) for other literals.
}
@para{
 We don't really need to do any fancy string-operations in order to find the zebra.
 We can totally add some string-functions to our @(racket primitives),
 like @(racket string-append) and, say, @(racket string-upcase),
 but we don't have to.
}

@subsection{@(racket equal?)}

@para{
 If we add @(racket equal?) to the @(racket primitives) we can use it for checking if things
 (e.g. strings, symbols) are equal.
}

@subsection{Recursive functions}

@para{
 The list is a recursive data structure. We might need recursive functions.
 Since our lists are Racket lists, our strings are Racket strings, and so on,
 we can probably get away with writing the recursive functions in Racket and just adding them as primitives.
 But it would be neat to add support for recursive functions to our language.
}
@para{
 One thing we can do is to combine it with adding support for more rackety function definitions,
 the ones that go @(racket (define (function-name arguments ...) body ...)).
 We can add a clause to the @(racket match) in @(racket eval-sequence):
}
@(racketblock
  [(list (list 'define (list name params ...) body ...) rest ...) #,(emph "your code here")])

@para{
 Here we must extend the environment with the function definition.
 To make the possibly recursive function, we make a helper-function:
}
@(racketblock
  (define (make-named-function env name parameters body)
    (λ (continue fail . arguments)
      #,(emph "your code here"))))

@para{
 This should behave mostly like @(racket make-function),
 only the function should add ``itself'' to the environment before adding the arguments to the environment.
 It can create a copy of ``itself'' by applying @(racket make-named-function) again.
 (We're really using Racket's support for recursive functions to build our own support for it.)
}

@section{Writing a zebra-program}

@para{
 One way to go about this:
}

@subsection{Some lists}
@para{
 We make a list of colours, a list of nationalities, and so on.
 Each element in the each list is an @(racket amb)-expression with the possible values.
 (We can optimize a bit: E.g. since the puzzle tells us that the norwegian lives in the first house,
 we don't need an @(racket amb) for the first element in the list of nationalities,
 and we don't need to include norwegian as a possible value for the other elements.)
}

@subsection{Some helper functions}

@para{We probably want some helper functions for stuff like:}

@(itemlist
  @item{
 Checking that a list contains no duplicate elements
 (we won't allow e.g. two red houses)
}
  @item{Getting the index of an element in a list}
  @item{
 Checking that one element in one list has the same index as another elemnt in another list
 (for things like ``the Englishman lives in the red house'')
}
  @item{@(racket abs) (or we can just include Racket's @(racket abs) in the @(racket primitives)}
  @item{
 Checking that one element has an index that is off by one from the index of another element in another list
 (for things like ``the Norwegian lives next to the blue house'')
 })

@subsection{The requirements}

@para{
 With the lists and the helper functions we can specify the different requirements.
}

@para{
 In order to make the program go faster, we should add the different requirements as soon as possible:
}

@(itemlist
  @item{After defining a list, we immediately require that it has no duplicate elements.}
  @item{
 After defining a list, we add all the requirements that we have the necessary lists for.
 Like, once we have defined a list of nationalities and a list of colours,
 we will add the requirements for
 ``the Englishman lives in the red house'' and ``the green house is immediately to the right of the ivory house''
 before defining more lists.
 })

@subsection{Return a list with all the lists}

@para{Return a list with all the lists.}

@section{Running the zebra-program}

@para{
 We can run the program with @(racket evaluate) to find one solution,
 and maybe run it with @(racket evaluate*) to check that there is only one solution.
}

@section[#:tag "zebra-done"]{Done?}

@para{OMG.}
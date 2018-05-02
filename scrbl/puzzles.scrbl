#lang scribble/manual
@(require scriblib/figure
          "util.rkt")

@title{It's puzzle time}

@intro-para["7-amb.rkt"]

@para{Now that we have our great evaluator with @(racket amb) and @(racket require), let us see what it can do! }

@section{Find the missing number}

@centered{@image[#:scale 0.5 "scrbl/images/cars.png"]}

@para{Do you ever see pictures like this one in your social media feeds? Well, now you have a language to solve them for you.}

@para{Write a program in our new language that solves this puzzle by the use @(racket amb) to define possible values 1 - 9 for the car colors, and @(racket require) to define the restrictions.}

@para{What happens if you allow the green car to also have the value -2?}

@section{Find the digits}

@centered{@image[#:scale 0.7 "scrbl/images/circles.png"]}

@para{Find the digits symbolized by the blue, red and white circles that fits into the calculation.}

@section{Sudoku}

@centered{@image[#:scale 1.0 "scrbl/images/sudoku.png"]}

@para{Our evaluator can also solve sudokus!}

@para{The easiest way is to require that the sums vertically, horizontally and inside each square are equal to 10.
 But then we might get more than one solution and manually select the one that follows the rules,
 because we have not incorporated the rule that the digits in same row, column or square should be distinct.}

@para{If we want to do it properly our program has to define a function that takes a list and decides if the elements in the list are unique.
One way to do that would be to loop through the list and check if the first element is contained in the rest of the list, if it is, the elements are not unique,
otherwise call the function with the rest of the list. (This function will also be useful for solving the Zebra puzzle).}

@para{The sudoku in the picture is from  @hyperlink["http://www.minisudoku.com/"]{minisudoku.com}. There are more sudokus there, and you can check your solution.}

@section[#:tag "puzzles-done"]{Done?}

@para{@secref{Towards_zebras}, then.}
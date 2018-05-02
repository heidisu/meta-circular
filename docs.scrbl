#lang scribble/manual
@(define scribblings '(("manual.scrbl" (multi-page))))

@title{Make your own meta-circular evaluator!}

@(author
  @elem{Jonas Winje (@(hyperlink "https://twitter.com/JonasWinje" "@JonasWinje"))}
  @elem{Heidi Mork (@(hyperlink "https://twitter.com/heidicmork" "@heidicmork"))})

@(table-of-contents)

@include-section{scrbl/meta-eval.scrbl}
@include-section{scrbl/racket.scrbl}
@include-section{scrbl/fix-calc.scrbl}
@include-section{scrbl/lookup.scrbl}
@include-section{scrbl/definitions.scrbl}
@include-section{scrbl/functions.scrbl}
@include-section{scrbl/cps.scrbl}
@include-section{scrbl/cps-refactor.scrbl}
@include-section{scrbl/bools.scrbl}
@include-section{scrbl/amb.scrbl}
@include-section{scrbl/puzzles.scrbl}
@include-section{scrbl/zebra.scrbl}
#lang scribble/manual

@(provide intro-para
          intro-test-para
          outro-test-para
          outro-para)

@(define (intro-para filename)
   @para{
 If we've been through the previous part, we can keep using the same file. Or we can use @tt[filename] as our starting point.
 })

@(define outro-test-para
   @para{
 Run and see that all the tests pass.
 })

@(define (outro-para section filename)
   @para{
 Next is @secref[section].
 We can keep using the Racket-file we're working with, or skip to @tt[filename].
 })

@(define intro-test-para
   @para{
 You might want to copy them into the test module at the bottom of your Racket file.
 The tests are going to fail at first. By the end of this chapter they should pass.
 })

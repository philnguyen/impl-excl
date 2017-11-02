[![Build Status](https://travis-ci.org/philnguyen/impl-excl.svg?branch=master)](https://travis-ci.org/philnguyen/impl-excl) impl-excl
=========================================

Compute procedures for fast checking of implications and exclusions between simple predicates.

### Install

```
raco pkg install impl-excl
```

### Examples

The follow code declares and checks for some relationships between predicates
from part of Racket's base types.

```racket
#lang racket/base
(require impl-excl)
(define-values (implies? excludes?)
  ;; Part of Racket's base types and tags
  (compute-impl-excl-procedures
   #:implications
   '([exact-integer? integer?] 
     [integer? real?]
     [real? number?]
     [exact-integer? exact?]
     [exact? number?]
     [inexact? number?]
     [positive? real?]
     [negative? real?]
     [zero? number?]
     [number? any/c]
     [not boolean?] ; `not` as alias for `false?`
     [boolean? any/c])
   #:exclusions
   '({boolean? number?}
     {exact? inexact?}
     {positive? negative? zero?})))
     
(implies?  'integer? 'number?)  ; ==> #t
(implies?  'not      'number? ) ; ==> #f
(excludes? 'not      'inexact?) ; ==> #t
```

Declaring redundant relations (e.g. those already implied by the graph) is harmless.

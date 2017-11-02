#lang typed/racket/base

(require typed/rackunit
         "main.rkt")

;; Declare direct implications and exclusions,
;; and have all transitive relations figured out once.
(define-values (implies? excludes?)
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
     [not boolean?] ; `not` as synonymous for `false?`
     [boolean? any/c])
   #:exclusions
   '({boolean? number?}
     {exact? inexact?}
     {positive? negative? zero?})))

(for* ([p '(not boolean?)]
       [q '(exact? positive? integer? number?)])
  
  (check-true (excludes? p q))
  (check-true (excludes? q p))
  (check-false (implies? p q))
  (check-false (implies? q p))
  
  (check-true (implies? p 'any/c))
  (check-true (implies? q 'any/c))
  (check-false (implies? 'any/c p))
  (check-false (implies? 'any/c q)))

(check-true (implies? 'integer? 'number?))


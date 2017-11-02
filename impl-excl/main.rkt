#lang typed/racket/base

(provide compute-impl-excl-procedures)

(require racket/set)

(: compute-impl-excl-procedures :
   #:implications (Listof (List Symbol Symbol))
   #:exclusions (Listof (Listof Symbol))
   → (Values (Symbol Symbol → Boolean) (Symbol Symbol → Boolean)))
(define (compute-impl-excl-procedures #:implications impls #:exclusions excls)

  (define implications   : (Mutable-HashTable Symbol (Setof Symbol)) (make-hasheq))
  (define exclusions     : (Mutable-HashTable Symbol (Setof Symbol)) (make-hasheq))
  (define implications⁻¹ : (Mutable-HashTable Symbol (Setof Symbol)) (make-hasheq))

  (: add-impl! : Symbol Symbol → Void)
  (define (add-impl! p q)
    (unless (implies? p q)
      (map-add! implications   p q)
      (map-add! implications⁻¹ q p)
      ;; reflexive
      (add-impl! p p)
      (add-impl! q q)
      ;; transitive
      (for ([q* (in-set (get-weakers q))])
        (add-impl! p q*))
      (for ([p* (in-set (get-strongers p))])
        (add-impl! p* q))
      ;; (r → ¬q) and (q₀ → q) implies r → ¬q₀
      (for ([r (in-set (get-excludeds q))])
        (add-excl! p r))))

  (: add-excl! : Symbol Symbol → Void)
  (define (add-excl! p q)
    (unless (excludes? p q)
      (map-add! exclusions p q)
      ;; (p → ¬q) and (q₀ → q) implies (p → ¬q₀)
      (for ([q₀ (in-set (get-strongers q))])
        (add-excl! p q₀))
      (for ([p₀ (in-set (get-strongers p))])
        (add-excl! p₀ q))
      ;; symmetric
      (add-excl! q p)))

  (: get-weakers   : Symbol → (Setof Symbol))
  (: get-strongers : Symbol → (Setof Symbol))
  (: get-excludeds : Symbol → (Setof Symbol))
  (define (get-weakers   p) (hash-ref implications   p mk-∅))
  (define (get-strongers p) (hash-ref implications⁻¹ p mk-∅))
  (define (get-excludeds p) (hash-ref exclusions     p mk-∅))
  (define implies?  (map-has? implications))
  (define excludes? (map-has? exclusions  ))

  (for ([impl (in-list impls)])
    (add-impl! (car impl) (cadr impl)))
  (for* ([excl-group (in-list excls)]
         [p (in-list excl-group)]
         [q (in-list excl-group)] #:unless (eq? p q))
    (add-excl! p q))
  
  (values implies? excludes?))

(: map-add! : (Mutable-HashTable Symbol (Setof Symbol)) Symbol Symbol → Void)
(define (map-add! m x y)
  (hash-update! m x (λ ([ys : (Setof Symbol)]) (set-add ys y)) mk-∅))

(: map-has? : (HashTable Symbol (Setof Symbol)) → Symbol Symbol → Boolean)
(define ((map-has? m) x y)
  (set-member? (hash-ref m x mk-∅) y))

(define mk-∅ (let ([∅ : (Setof Symbol) (seteq)]) (λ () ∅)))

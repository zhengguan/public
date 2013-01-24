#lang racket

(require "../software/cs4800.rkt" "../software/big-o.rkt" rackunit)

(current-print pretty-print-handler)

(define/cost (faster-sort stuff)
  (define N (len stuff))
  (cond
    [(<= N 1) stuff]
    [else
     (define N/2 (quotient N 2))
     (define both-halves (bifurcate-list stuff N/2))
     (define first-half (first both-halves))
     (define second-half (second both-halves))
     (define sorted-first-half (faster-sort first-half))
     (define sorted-second-half (faster-sort second-half))
     (define sorted
       (combine-sorted-lists sorted-first-half sorted-second-half))
     sorted]))

(define/cost (len stuff)
  (cond
    [(empty? stuff) 0]
    [else (add1 (len (rest stuff)))]))

;; bifurcate-list : (Listof X) Number -> (list (Listof X) (Listof X))
(define/cost (bifurcate-list stuff size-of-first-half)
  (cond
    [(zero? size-of-first-half) (list empty stuff)]
    [else
     (define bifurcated-rest
       (bifurcate-list (rest stuff) (sub1 size-of-first-half)))
     (list
       (cons (first stuff) (first bifurcated-rest))
       (second bifurcated-rest))]))

(check-equal? (bifurcate-list (list 2 1) 0)     (list empty (list 2 1)))
(check-equal? (bifurcate-list (list 3 2 1) 1)   (list (list 3) (list 2 1)))
(check-equal? (bifurcate-list (list 4 3 2 1) 2) (list (list 4 3) (list 2 1)))

;; combine-sorted-lists : (Listof X) (Listof X) -> (Listof X)
(define/cost (combine-sorted-lists one two)
  (cond
    [(empty? one) two]
    [(empty? two) one]
    [else
     (cond
       [(< (first one) (first two))
        (cons (first one)
          (combine-sorted-lists (rest one) two))]
       [else
        (cons (first two)
          (combine-sorted-lists one (rest two)))])]))

(check-equal?
  (combine-sorted-lists (list 2 3 7 8) (list 0 1 4 5))
  (list 0 1 2 3 4 5 7 8))

(check-equal?
  (faster-sort (list 2 8 7 3 5 4 1 0))
  (list 0 1 2 3 4 5 7 8))

;; sort : (Listof Number) -> (Listof Number)
;; Sorts the input list in ascending order.
(define/cost (sort stuff)
  (if (empty? stuff)
    stuff
    (put-into-stuff (first stuff)
      (sort (rest stuff)))))

;; put-into-stuff : Number (Listof Number)
;; Put one thing into a bunch of sorted stuff.
(define/cost (put-into-stuff thing stuff)
  (if (empty? stuff)
    (cons thing empty)
    (if (< thing (first stuff))
      (cons thing stuff)
      (cons (first stuff)
        (put-into-stuff thing (rest stuff))))))

(define (best-case i) (build-list i identity))
(define (worst-case i) (reverse (best-case i)))

(current-cost-model
  (cost-model
    cons 1
    first 1
    second 2
    rest 1
    empty? 1
    list (lambda xs (length xs))
    < 1
    <= 1
    quotient 1
    zero? 1
    sub1 1
    add1 1))

(for/list {[i (list 10 20 30 40 50)]}
  (define xs (worst-case i))
  (list
    i
    (* i (log i))
    (cost-of (faster-sort xs))
    (cost-of (sort xs))))

(for/list {[i (list 10 20 30 40 50)]}
  (define xs (best-case i))
  (list
    i
    (cost-of (faster-sort xs))
    (cost-of (sort xs))))

(define (cost-of-merge-sort n)
  (define xs (worst-case n))
  (cost-of (faster-sort xs)))

(define (n-log-n n)
  (* n (log n)))

(O? cost-of-merge-sort n-log-n 25 10 random-small-number)
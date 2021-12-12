; --- Day 12: Passage Pathing ---

#lang racket

(define (add-connection graph from to)
  (let ([caves (hash-ref graph from '())])
    (if (member to caves) graph
      (add-connection (hash-set graph from (cons to caves)) to from))))

(define (build-caves-graph lines graph)
  (if (null? lines) graph
    (let ([connection (string-split (car lines) "-")])
      (build-caves-graph (cdr lines) (add-connection graph (car connection) (car (cdr connection)))))))

(define (uppercase? string)
  (string=? (string-upcase string) string))

(define (valid-with-no-small-cave-repeat? cave path)
  (or (uppercase? cave) (not (member cave path))))

(define (valid-with-one-small-cave-repeat? cave path)
  (or
    (valid-with-no-small-cave-repeat? cave path)
    (and (not (member cave '("start" "end")))
         (not (check-duplicates (filter-not uppercase? path))))))

(define (next-caves graph path predicate)
  (let ([caves (hash-ref graph (car path) '())])
    (filter (λ (cave) (predicate cave path)) caves)))

(define (continue-paths graph path predicate)
  (map (λ (cave) (cons cave path)) (next-caves graph path predicate)))

(define (all-paths graph in-progress completed predicate)
  (if (null? in-progress) completed
    (let ([path (car in-progress)])
      (if (equal? (car path) "end")
        (all-paths graph (cdr in-progress) (cons (reverse path) completed) predicate)
        (all-paths graph (append (continue-paths graph path predicate) (cdr in-progress)) completed predicate)))))


(define input
  (string-split
    (string-trim
      (port->string
        (open-input-file "inputs/input12.txt")
        #:close? #t))
    "\n"))

(define graph (build-caves-graph input (make-immutable-hash)))
(display (length (all-paths graph '(("start")) '() valid-with-no-small-cave-repeat?)))
(newline)
(display (length (all-paths graph '(("start")) '() valid-with-one-small-cave-repeat?)))
(newline)

; racket day12.rkt
; 5920
; 155477

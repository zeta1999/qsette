; Based on the Simple Grover sample
; https://github.com/microsoft/Quantum/tree/master/samples/algorithms/simple-grover
;
; Copyright (c) Microsoft Corporation. All rights reserved.
; Licensed under the MIT License.

#lang rosette

(require "../qsette.rkt"
         "../probability.rkt")

(define num-qubits 2)

(define num-iterations
  (let* ([angle (asin (/ 1 (sqrt (expt 2 num-qubits))))]
         [iterations (exact-round (- (/ pi 4 angle) (/ 1 2)))])
    iterations))

(operation (reflect-target qs target)
  (using ([p (qubit)])
    (x p)
    (controlled-on-bit-string z target qs p)
    (x p)))

(operation (reflect-uniform qs)
  (begin
    (apply-to-each h qs)
    (apply-to-each x qs)
    (controlled z (drop qs 1) (index qs 0))
    (apply-to-each x qs)
    (apply-to-each h qs)))

(operation (grover-search target)
  (begin
    (mutable result #f)
    (using ([qs (qubits ,num-qubits)])
      (apply-to-each h qs)
      (for (i ,num-iterations)
        (begin
          (,reflect-target qs target)
          (,reflect-uniform qs)))
      (set result (measure-integer qs)))
    (return result)))

(probability/v (grover-search (bv 3 num-qubits)) (bv 3 num-qubits))
(clear-asserts!)
(probability/v (grover-search (bv 0 num-qubits)) (bv 0 num-qubits))
(clear-asserts!)

(define-symbolic n (bitvector num-qubits))

(time (verify (assert (<= 0.97 (probability/v (grover-search n) n)))))
(time (verify (assert (<= 0.8 (probability/v (grover-search n) n)))))
(time (verify (assert (= 1 (probability/v (grover-search n) n)))))
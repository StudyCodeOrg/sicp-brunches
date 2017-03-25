#lang racket
(require (except-in "utils.scm" square))
(provide (all-defined-out))



;;;-----------
;;;from section 3.3.3 for section 2.4.3
;;; to support operation/type table for data-directed dispatch

(define (assoc key records)
  (cond ((null? records) false)
        ((equal? key (caar records)) (car records))
        (else (assoc key (cdr records)))))

(define (make-table)
  (let [[local-table (list '(*table*))]]
    (define (lookup key-1 key-2)
      (define (inner in-table)
        (cond
          [(empty? in-table) #f]
          [(equal? (first (first in-table)) (list key-1 key-2))
            (second (first in-table))]
          [else (inner (rest in-table))]
          ))
      (inner local-table))
    (define (insert! key-1 key-2 value)
      (if (lookup key-1 key-2) (error "Cannot overwrite existing key")
          (set! local-table (cons (list (list key-1 key-2) value) local-table))))
    (define (show)
      (prn local-table))
    (define (dispatch m)
      (cond ((eq? m 'lookup-proc) lookup)
            ((eq? m 'insert-proc!) insert!)
            ((eq? m 'show) show)
            (else (error "Unknown operation -- TABLE" m))))
    dispatch))

(define operation-table (make-table))
(define get (operation-table 'lookup-proc))
(define put (operation-table 'insert-proc!))

(define coercion-table (make-table))
(define get-coercion (coercion-table 'lookup-proc))
(define put-coercion (coercion-table 'insert-proc!))

(define (apply-generic op . args)
  ;(prn 'apply-generic op args)
  (let*
    [(type-tags (map type-tag args))
     (proc (get op type-tags))
     (procargs (map contents args))]
    (cond
        [proc (apply proc procargs)]
        [(= (length args) 2)
          (let*
            [(t1 (first type-tags))
             (t2 (second type-tags))
             (t1->t2 (get-coercion t1 t2))
             (t2->t1 (get-coercion t2 t1))
             (a1 (first args))
             (a2 (second args))]
            (cond
              ((= t1 t2) (error "No method or coercion for these types" (list op type-tags)))
              (t1->t2 (apply-generic op (t1->t2 a1) a2))
              (t2->t1 (apply-generic op a1 (t2->t1 a2)))
              (else
                (error "No method or coercion for these types" (list op type-tags)))
              ))]
          [else (error "No method for these types -- APPLY-GENERIC" (list op type-tags))])))


(define (attach-tag type-tag contents)
  (cond
    [(number? contents) contents]
    [else (cons type-tag contents)]))

(define (type-tag datum)
  (cond [(pair? datum) (car datum)]
        [(number? datum) 'scheme-number]
      (error "Bad tagged datum -- TYPE-TAG" datum)))

(define (contents datum)
  ;(prn datum "")
  (cond
    [(number? datum) datum]
    [(and (list? datum) (equal? 2 (length datum))) (first (cdr datum))]
    [(pair? datum) (cdr datum)]
    [else (error "Bad tagged datum -- CONTENTS" datum)]))


(module* main #f
  (assert "Nothing in an empty table" (not (get 'a 'b)))
  (void (put 'a 'b 123))
  (assertequal? "We can lookup what we inserted" 123 (get 'a 'b))
)

#lang racket
(require "../utils.scm")
(require "../meta.scm")

(require "./exercise-2.56.scm")

;   Exercise 2.57
;   =============
;
;   Extend the differentiation program to handle sums and products of
;   arbitrary numbers of (two or more) terms. Then the last example above
;   could be expressed as
;
;   (deriv '(* x y (+ x 3)) 'x)
;
;   Try to do this by changing only the representation for sums and
;   products, without changing the deriv procedure at all.  For example, the
;   addend of a sum would be the first term, and the augend would be the sum
;   of the rest of the terms.
;
;   ------------------------------------------------------------------------
;   [Exercise 2.57]: http://sicp-book.com/book-Z-H-16.html#%_thm_2.57
;   2.3.2 Example: Symbolic Differentiation - p151
;   ------------------------------------------------------------------------

(module* main #f
  (title "Exercise 2.57")

  (define-syntax make-maker
  	(syntax-rules ()
  		[(_ operator)
        (lambda args
          (cond
            ((< (length args) 2)
              (error "Can't operate on one value"))
            ((findf number? args)
              (append
                (list (quote operator))
                (list (apply operator (filter number? args)))
                (filter (lambda (x) (not (number? x))) args)))
            (else
              (cons (quote operator) args)))) ]))

  (define make-sum (make-maker +))
  (define make-product (make-maker *))

  (let*
    (
      (sum? (lambda (x) (and (list? x) (eq? (car x) '+))))
      (addend (lambda (xs) (second xs)))
      (augend (lambda (xs)
        (if (> (length xs) 3)
          (cons '+ (rest (rest xs)))
          (third xs))))

      (product? (lambda (x) (and (list? x) (eq? (car x) '*))))
      (multiplier (lambda (xs) (second xs)))
      (multiplicand (lambda (xs)
        (if (> (length xs) 3)
          (cons '* (rest (rest xs)))
          (third xs))))

      (TESTSUM (make-sum 'a 'b 'c 'd))
      (TESTPRODUCT (make-product 'a 'b 'c 'd))
    )

    (assertequal? "We can make sums of multiple values" '(+ a b c d) TESTSUM)
    (assertequal? "We can get the augend of a long sum" '(+ b c d) (augend TESTSUM))
    (assertequal? "We can get the addend of a long sum" 'a (addend TESTSUM))
    (assertequal? "We can make sums of two values" '(+ a b) (make-sum 'a 'b))
    (assertequal? "We can get the addend of a simple sum" 'a (addend (make-sum 'a 'b)))
    (assertequal? "We can get the augend of a simple sum" 'b (augend (make-sum 'a 'b)))
    (assertequal? "Sum will collapse numbers together when at the front" '(+ 3 c) (make-sum 1 2 'c))
    (assertequal? "Sum will collapse numbers together when at the back" '(+ 5 a) (make-sum 'a 2 3))
    (assertequal? "Sum will collapse numbers together when in the middle" '(+ 5 a d) (make-sum 'a 2 3 'd))
    (assertequal? "Sum will collapse numbers together anywhere" '(+ 5 a d) (make-sum 1 'a 2 1 'd 1))

    (assertequal? "We can make products of multiple values" '(* a b c d) (make-product 'a 'b 'c 'd))
    (assertequal? "We can get the multiplicand of a long product" '(* b c d) (multiplicand (make-product 'a 'b 'c 'd)))
    (assertequal? "We can get the multiplier of a long product" 'a (multiplier (make-product 'a 'b 'c 'd)))
    (assertequal? "we can make products out of two numbers " '(* a b) (make-product 'a 'b))
    (assertequal? "we can get the multiplier out of a simple product " 'a (multiplier (make-product 'a 'b)))
    (assertequal? "we can get the multiplicand out of a simple product " 'b (multiplicand (make-product 'a 'b)))
    (assertequal? "Product will collapse numbers together when at the front" '(* 2 c) (make-product 1 2 'c))
    (assertequal? "Product will collapse numbers together when at the back" '(* 6 a ) (make-product 'a 2 3))
    (assertequal? "Product will collapse numbers together when in the middle" '(* 6 a d) (make-product 'a 2 3 'd))
    (assertequal? "Product will collapse numbers together anywhere" '(* 30 b e) (make-product 1 'b 2 3 'e 5))
  )
)
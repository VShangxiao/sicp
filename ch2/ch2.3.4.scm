;;;; SICP Chapter 2.3.4
;;;;  Huffman Encoding Tree
;;;;
;;;; Author @uents on twitter
;;;;

#lang racket

(require "../misc.scm")


;;;; 2.3.4 Huffman符号化木

;;; leaf 

(define (leaf? object)
  (eq? (car object) 'leaf))

(define (symbol-leaf x) (cadr x))

(define (weight-leaf x) (caddr x))

(define (make-leaf symbol weight)
  (list 'leaf symbol weight))


;;; tree

(define (left-branch tree) (car tree))

(define (right-branch tree) (cadr tree))

(define (symbols tree)
  (if (leaf? tree)
      (list (symbol-leaf tree))
      (caddr tree)))

(define (weight tree)
  (if (leaf? tree)
      (weight-leaf tree)
      (cadddr tree)))

(define (make-code-tree left right)
  (list left
        right
        (append (symbols left) (symbols right))
        (+ (weight left) (weight right))))


;;; decoding

(define (decode bits tree)
  (define (decode-1 bits current-branch)
    (if (null? bits)
        '()
        (let ((next-branch
               (choose-branch (car bits) current-branch)))
          (if (leaf? next-branch)
              (cons (symbol-leaf next-branch)
                    (decode-1 (cdr bits) tree))
              (decode-1 (cdr bits) next-branch)))))
  (decode-1 bits tree))

(define (choose-branch bit branch)
  (cond ((= bit 0) (left-branch branch))
        ((= bit 1) (right-branch branch))
        (else (error "bad bit -- CHOOSE-BRANCH" bit))))


;;; sets

(define (adjoin-set x set)
  (cond ((null? set) (list x))
        ((< (weight x) (weight (car set))) (cons x set))
        (else (cons (car set)
                    (adjoin-set x (cdr set))))))

(define (make-leaf-set pairs)
  (if (null? pairs)
      '()
      (let ((pair (car pairs)))
        (adjoin-set (make-leaf (car pair)
                               (cadr pair))
                    (make-leaf-set (cdr pairs))))))


;;; ex 2.67

(define sample-tree
  (make-code-tree (make-leaf 'A 4)
                  (make-code-tree
                   (make-leaf 'B 2)
                   (make-code-tree (make-leaf 'D 1)
                                   (make-leaf 'C 1)))))

(define sample-message '(0 1 1 0 0 1 0 1 0 1 1 1 0))

#|
(decode sample-message sample-tree)
;; => '(A D A B B C A)
|#

;;; ex 2.68

(define (encode message tree)
  (if (null? message)
      '()
      (append (encode-symbol (car message) tree)
              (encode (cdr message) tree))))

(define (encode-symbol symbol tree)
   (if (null? (memq symbol (symbols tree)))
 	  #f
 	  (encode-symbol-1 symbol tree nil)))

(define (encode-symbol-1 symbol tree bits)
  (cond ((leaf? tree)
		 bits)
		((memq symbol (symbols (left-branch tree)))
		 (encode-symbol-1 symbol
						  (left-branch tree)
						  (append bits (list 0))))
		(else
		 (encode-symbol-1 symbol
						  (right-branch tree)
						  (append bits (list 1))))))

#|
(equal?
 sample-message
 (encode (decode sample-message sample-tree) sample-tree))
;;=> #t
|#

;;; ex 2.69
;;; p.96 Huffman木の生成 のアルゴリズムを再現する

(define (generate-huffman-tree pairs)
  (successive-merge (make-leaf-set pairs)))

(define (successive-merge tree)
  (cond ((null? tree) nil)
		((null? (cdr tree)) (car tree))
		(else
		 (successive-merge
		  (adjoin-set (make-code-tree (car tree) (cadr tree))
					  (cddr tree))))))

#|
(define sample-tree-2
  (generate-huffman-tree '((A 4) (B 2) (D 1) (C 1))))

(equal?
 sample-message
 (encode (decode sample-message sample-tree-2) sample-tree-2))
;;=> #t
|#


; p.s. 間違った解。これだと右に偏った木になってしまう
;
;(define (successive-merge leafs)
;  (if (null? leafs)
;	  nil
;	  (successive-merge-1 (cdr leafs) (car leafs))))
;
;(define (successive-merge-1 leafs tree)
;  (if (null? leafs)
;	  tree
;	  (successive-merge-1 (cdr leafs)
;						  (make-code-tree (car leafs) tree))))



;;; ex 2.70

(define word-pairs
  (list '(A 2)
		'(BOOM 1)
		'(GET 2)
		'(JOB 2)
		'(NA 16)
		'(SHA 3)
		'(YIP 9)
		'(WAH 1)))

(define song-lyrics
  '(GET A JOB
	SHA NA NA NA NA NA NA NA NA
	GET A JOB
	SHA NA NA NA NA NA NA NA NA
	WAH YIP YIP YIP YIP YIP YIP YIP YIP YIP
	SHA BOOM))


#|
(define word-tree (generate-huffman-tree word-pairs))

(equal?
 song-lyrics
 (decode (encode song-lyrics word-tree) word-tree))
;;=> #t
 
(length (encode song-lyrics word-tree))
;;=> 84
|#

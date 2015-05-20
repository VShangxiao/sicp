
(load "../misc.scm")
(load "./data_types.scm")
(load "./environment.scm")
(load "./evaluator.scm")
(load "./special_forms.scm")
(load "./parser.scm")

(define the-global-environment (setup-environment))

(define (repl)
  (input-prompt)
  (let* ((input (read))
		 (output (eval-proc (parse input)
							the-global-environment)))
	(output-prompt)
	(user-print output))
  (repl))

(define (input-prompt)
  (newline)
  (display ";;; M-Eval input:")
  (newline))

(define (output-prompt)
  (newline)
  (display ";;; M-Eval value:")
  (newline))

(define (user-print object)
  (display object)
  (newline))

;; (if (compound-procedure? object)
  ;;     (display (list 'compound-procedure
  ;;                    (procedure-parameters object)
  ;;                    (procedure-body object)
  ;;                    '<procedure-env>))
  ;;     (display object)))

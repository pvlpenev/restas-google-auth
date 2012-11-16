;;;; package.lisp

(restas:define-module #:restas-google-auth
    (:use #:cl)
  (:export #:*redirect-uri*
	   #:*login-function*
	   #:*logout-function*
	   #:*host*
	   #:get-message-email
	   #:simple-get-user-auth
	   #:logout
	   #:get-auth-url))

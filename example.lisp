(restas:define-module #:google-test
    (:use #:cl)
  (:export #:start
	   #:start2))

(in-package #:google-test)

(restas:define-route main ("")
  (if (hunchentoot:session-value :auth)
      (format nil "~a <a href=\"~a\">log out</a>"
	      (hunchentoot:session-value :auth)
	      ;; generate logout url
	      (restas:genurl-submodule 'google-auth 'restas-google-auth:logout))
      (format nil "<a href=\"~a\">Log in</a>"
	      ;; get the google url for authentication
	      (restas-google-auth:get-auth-url))))

(defun start ()
  (restas:mount-submodule google-auth (#:restas-google-auth)
    (restas-google-auth:*baseurl* '("google")) ; optional
    (restas-google-auth:*host* "localhost:8080")
    (restas-google-auth:*redirect-uri* "/"))
  (restas:start '#:google-test :port 8080 :hostname "localhost"))

(defun start2 ()
  (restas:mount-submodule google-auth (#:restas-google-auth)
    (restas-google-auth:*baseurl* '("google")) ; optional
    (restas-google-auth:*host* "localhost:8080")
    (restas-google-auth:*redirect-uri* "/")
    (restas-google-auth:*login-function*
     #'(lambda (message)
	 (setf (hunchentoot:session-value :auth)
	       (restas-google-auth:get-message-email message))))
    (restas-google-auth:*logout-function*
     #'(lambda ()
	 (setf (hunchentoot:session-value :auth) nil))))
  (restas:start '#:google-test :port 8080 :hostname "localhost"))

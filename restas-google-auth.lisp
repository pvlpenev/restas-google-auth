;;;; restas-google-auth.lisp

(in-package #:restas-google-auth)

;;; "restas-google-auth" goes here. Hacks and glory await!

(defparameter *relying-party* nil)
(defparameter *google-auth-url* "https://www.google.com/accounts/o8/id")
(defparameter *host* nil)

(defparameter *login-function* nil)
(defparameter *logout-function* nil)

;;; initialization. Gets called when the module is mounted with restas:mount-submodule
(defmethod restas:initialize-module-instance :before ((module (eql #.*package*)) context)
  (restas:with-context context
    (restas:context-add-variable
     context '*relying-party*
     (let* ((realm (format nil "http://~A" *host*))
	    (root-uri (format nil "~A~A" realm (restas:genurl 'auth))))
       (make-instance 'cl-openid:relying-party
		      :realm (puri:uri realm)
		      :root-uri (puri:uri root-uri)))))
  
  ;; Because context variables in restas are available only in
  ;; routes, an ordinary function using them needs to be defined at
  ;; module initialization time, to capture the value of context,
  ;; where the variables are stored.
  (defun get-auth-url ()
    (restas:with-context context
      (cl-openid:initiate-authentication
       *relying-party* 
       *google-auth-url*
       ;; fetch the email of the user using attribute exchange extention
       :extra-parameters
       '("openid.ns.ax" "http://openid.net/srv/ax/1.0"
	 "openid.ax.mode" "fetch_request"
	 "openid.ax.required" "email"
	 "openid.ax.type.email" "http://axschema.org/contact/email")))))

(defun get-message-email (message)
  (cdr (assoc "openid.ext1.value.email" message :test #'string=)))

(defun simple-login (message)
  (setf (hunchentoot:session-value :auth)
	(get-message-email message)))

(defun simple-logout ()
  (setf (hunchentoot:session-value :auth) nil))

(defun simple-get-user-auth ()
  (hunchentoot:session-value :auth))

(restas:define-route auth ("auth")
  "Callback route"
  (let ((message (hunchentoot:get-parameters hunchentoot:*request*)) 
	(request-uri (puri:merge-uris (hunchentoot:request-uri hunchentoot:*request*) 
				      (cl-openid:root-uri *relying-party*)))
	authenticated-id)
    (handler-case
	(setf authenticated-id
	      (cl-openid:handle-indirect-response *relying-party* message request-uri))
      (error (c) (return-from auth (format nil "Error: ~A" c))))
    (when authenticated-id
      (if *login-function*
	  (funcall *login-function* message)
	  (simple-login message))
      (hunchentoot:redirect *redirect-uri*))))

(restas:define-route logout ("logout")
  "Route to log out the user, and reset the request token"
  (if *login-function*
      (funcall *logout-function*)
      (simple-logout))
  (hunchentoot:redirect *redirect-uri*))

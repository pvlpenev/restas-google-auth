;;;; restas-google-auth.asd
;;; Copyright (C) 2012 Pavel Penev
;;; All rights reserved.
;;; See the file LICENSE for terms of use and distribution.

(asdf:defsystem #:restas-google-auth
  :serial t
  :description "Google authentication plugin for restas"
  :author "Pavel Penev <pvl.penev@gmail.com>"
  :license "MIT"
  :depends-on (#:restas
               #:cl-openid)
  :components ((:file "package")
               (:file "restas-google-auth")))


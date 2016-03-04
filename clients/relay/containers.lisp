#|
 This file is a part of Colleen
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.colleen.clients.relay)

(defclass subscription ()
  ((id :initarg :id :accessor id)
   (target :initarg :target :accessor target)
   (subscriber :initarg :subscriber :accessor subscriber)
   (event-type :initarg :event-type :accessor event-type)
   (filter :initarg :filter :accessor filter))
  (:default-initargs
   :id (uuid:make-v4-uuid)
   :target T
   :subscriber (error "SUBSCRIBER required.")
   :event-type (error "EVENT-TYPE required.")
   :filter T))

(defclass transport ()
  ((event :initarg :event :accessor event)
   (target :initarg :target :accessor target)))

(defmethod print-object ((transport transport) stream)
  (print-unreadable-object (transport stream :type T)
    (format stream "~s ~s ~s" :to (target transport) (event transport))))

(defmethod make-transport ((event event) target)
  (make-instance 'transport :event event :target target))

(defclass network-update ()
  ((new :initarg :new :accessor new)
   (bad :initarg :bad :accessor bad))
  (:default-initargs
   :new () :bad ()))

(defmethod print-object ((update network-update) stream)
  (print-unreadable-object (update stream :type T)
    (format stream "~s ~s ~s ~s" :new (new update) :bad (bad update))))

(defmethod make-network-update ((new list) (bad relay))
  (make-network-update new (mapcar #'second (network bad))))

(defmethod make-network-update ((new list) (bad list))
  (make-instance 'network-update :new new :bad bad))

(defmethod make-network-update ((new network-update) (special null))
  (make-instance 'network-update
                 :new (loop for (hops destination) in (new new)
                            collect (list (1+ hops) destination))
                 :bad (bad new)))

(define-consumer virtual-client (client)
  ((links :initarg :links :accessor links))
  (:default-initargs
   :links ()))

(defmethod make-virtual-client ((target uuid:uuid) &optional links)
  (make-instance 'virtual-client :id target :links links))

(defmethod make-virtual-client ((target string) &optional links)
  (make-virtual-client (uuid:make-uuid-from-string target) links))

(defmethod make-virtual-client ((target named-entity) &optional links)
  (make-virtual-client (id target) links))
